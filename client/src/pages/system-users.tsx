import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Form, FormControl, FormField, FormItem, FormLabel } from '@/components/ui/form';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useToast } from '@/hooks/use-toast';
import { apiRequest } from '@/lib/queryClient';
import { Users, Plus, Edit, Trash2, Shield, Building2, KeyRound } from 'lucide-react';
import usePermissions from '@/hooks/usePermissions';
import { useModule, MODULE_CONFIGS } from '@/contexts/ModuleContext';

const createUserSchema = z.object({
  username: z.string().min(1, 'Username é obrigatório'),
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'Senha deve ter no mínimo 6 caracteres'),
  name: z.string().min(1, 'Nome é obrigatório'),
  role: z.enum(['admin', 'gestor_cliente', 'supervisor_site', 'operador', 'auditor']),
});

type CreateUserForm = z.infer<typeof createUserSchema>;
type User = {
  id: string;
  username: string;
  email: string;
  name: string;
  role: string;
  userType: string;
  assignedClientId?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
};

export default function SystemUsers() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const { can } = usePermissions();
  const { currentModule } = useModule();
  const [searchTerm, setSearchTerm] = useState('');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);

  const form = useForm<CreateUserForm>({
    resolver: zodResolver(createUserSchema),
    defaultValues: {
      username: '',
      email: '',
      password: '',
      name: '',
      role: 'operador',
    },
  });

  // Verificar se o usuário pode gerenciar usuários OPUS
  if (!can.viewOpusUsers()) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <Card className="w-96">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Acesso Negado
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              Você não tem permissão para acessar o gerenciamento de usuários do sistema.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Buscar apenas usuários OPUS (tipo opus_user)
  const OPUS_COMPANY_ID = "de722500-9ce3-4b13-8a1d-cddcb168551e";
  const { data: users = [], isLoading } = useQuery<User[]>({
    queryKey: ['/api/system-users'],
  });

  const createUserMutation = useMutation({
    mutationFn: async (data: CreateUserForm) => {
      await apiRequest('POST', '/api/system-users', {
        ...data,
        userType: 'opus_user',
        companyId: OPUS_COMPANY_ID,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/system-users'] });
      setIsCreateDialogOpen(false);
      setEditingUser(null);
      form.reset();
      toast({
        title: 'Sucesso',
        description: 'Usuário do sistema criado com sucesso!',
      });
    },
    onError: (error) => {
      toast({
        title: 'Erro',
        description: error.message,
        variant: 'destructive',
      });
    },
  });

  const updateUserMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<CreateUserForm> }) => {
      await apiRequest('PATCH', `/api/system-users/${id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/system-users'] });
      setIsCreateDialogOpen(false);
      setEditingUser(null);
      form.reset();
      toast({
        title: 'Sucesso',
        description: 'Usuário atualizado com sucesso!',
      });
    },
    onError: (error) => {
      toast({
        title: 'Erro',
        description: error.message,
        variant: 'destructive',
      });
    },
  });

  const toggleUserStatusMutation = useMutation({
    mutationFn: async ({ id, isActive }: { id: string; isActive: boolean }) => {
      await apiRequest('PATCH', `/api/system-users/${id}/status`, { isActive });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/system-users'] });
      toast({
        title: 'Sucesso',
        description: 'Status do usuário atualizado!',
      });
    },
    onError: (error) => {
      toast({
        title: 'Erro',
        description: error.message,
        variant: 'destructive',
      });
    },
  });

  const resetPasswordMutation = useMutation({
    mutationFn: async (userId: string) => {
      const tempPassword = Math.random().toString(36).slice(-8) + Math.random().toString(36).slice(-4).toUpperCase();
      await apiRequest('PATCH', `/api/system-users/${userId}`, { password: tempPassword });
      return tempPassword;
    },
    onSuccess: (tempPassword, userId) => {
      const user = users.find((u: User) => u.id === userId);
      queryClient.invalidateQueries({ queryKey: ['/api/system-users'] });
      toast({
        title: 'Senha Resetada!',
        description: (
          <div>
            <p className="font-bold">Nova senha para {user?.username}:</p>
            <p className="font-mono text-lg mt-2 bg-primary/20 p-2 rounded">{tempPassword}</p>
            <p className="text-xs mt-2">Copie esta senha e compartilhe com segurança.</p>
          </div>
        ),
        duration: 30000,
      });
    },
    onError: (error) => {
      toast({
        title: 'Erro ao resetar senha',
        description: error.message,
        variant: 'destructive',
      });
    },
  });

  const filteredUsers = users.filter((user: User) =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.username.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleEdit = (user: User) => {
    setEditingUser(user);
    form.reset({
      username: user.username,
      email: user.email,
      name: user.name,
      role: user.role as any,
      password: '', // Não pré-carregar senha
    });
    setIsCreateDialogOpen(true);
  };

  const handleSubmit = (data: CreateUserForm) => {
    if (editingUser) {
      // Remover password se estiver vazia na edição
      const updateData = data.password ? data : { ...data, password: undefined };
      updateUserMutation.mutate({ id: editingUser.id, data: updateData });
    } else {
      createUserMutation.mutate(data);
    }
  };

  const getCustomRoleName = (user: User & { customRoles?: any[] }) => {
    if (user.customRoles && user.customRoles.length > 0) {
      return user.customRoles[0].role.name;
    }
    // Fallback para usar o role padrão do usuário
    switch (user.role) {
      case 'admin':
        return 'Administrador';
      case 'gestor_cliente':
        return 'Gestor de Cliente';
      case 'supervisor_site':
        return 'Supervisor de Local';
      case 'operador':
        return 'Operador';
      case 'auditor':
        return 'Auditor';
      default:
        return null;
    }
  };

  const getRoleBadgeColor = (user: User & { customRoles?: any[] }) => {
    const customRole = getCustomRoleName(user);
    
    if (customRole) {
      // Cores para custom roles
      if (customRole.toLowerCase().includes('admin')) return 'destructive';
      if (customRole.toLowerCase().includes('cliente')) return 'default';
      if (customRole.toLowerCase().includes('operador')) return 'outline';
      return 'secondary';
    }
    
    // Fallback para roles antigos (se não tiver custom role)
    switch (user.role) {
      case 'admin':
        return 'destructive';
      case 'gestor_cliente':
        return 'default';
      case 'supervisor_site':
        return 'secondary';
      case 'operador':
        return 'outline';
      case 'auditor':
        return 'secondary';
      default:
        return 'outline';
    }
  };

  const getRoleLabel = (user: User & { customRoles?: any[] }) => {
    const customRole = getCustomRoleName(user);
    if (customRole) {
      return customRole;
    }
    
    // Fallback para roles antigos
    switch (user.role) {
      case 'admin':
        return 'Administrador';
      case 'gestor_cliente':
        return 'Gestor de Cliente';
      case 'supervisor_site':
        return 'Supervisor de Local';
      case 'operador':
        return 'Operador';
      case 'auditor':
        return 'Auditor';
      default:
        return user.role;
    }
  };

  if (isLoading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="text-muted-foreground">Carregando...</div>
      </div>
    );
  }

  return (
    <div className="flex-1 p-6 space-y-6">
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold text-foreground flex items-center gap-3">
            <Building2 className="h-8 w-8" />
            Usuários do Sistema OPUS
          </h1>
          <p className="text-muted-foreground mt-2">
            Gerenciar funcionários da empresa {MODULE_CONFIGS[currentModule].displayName}
          </p>
        </div>

        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button 
              onClick={() => {
                setEditingUser(null);
                form.reset();
              }}
              data-testid="button-create-system-user"
            >
              <Plus className="h-4 w-4 mr-2" />
              Novo Usuário OPUS
            </Button>
          </DialogTrigger>
          <DialogContent className="max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                {editingUser ? 'Editar Usuário OPUS' : 'Novo Usuário OPUS'}
              </DialogTitle>
              <DialogDescription>
                {editingUser ? 'Edite os dados do usuário' : `Crie um novo funcionário da ${MODULE_CONFIGS[currentModule].displayName}`}
              </DialogDescription>
            </DialogHeader>

            <Form {...form}>
              <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
                <FormField
                  control={form.control}
                  name="username"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Username</FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="usuario123"
                          data-testid="input-username"
                          {...field} 
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={form.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Email</FormLabel>
                      <FormControl>
                        <Input 
                          type="email"
                          placeholder="usuario@grupoopus.com"
                          data-testid="input-email"
                          {...field} 
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Nome Completo</FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="João Silva"
                          data-testid="input-name"
                          {...field} 
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="password"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>
                        {editingUser ? 'Nova Senha (deixe vazio para manter)' : 'Senha'}
                      </FormLabel>
                      <FormControl>
                        <Input 
                          type="password"
                          placeholder={editingUser ? "Nova senha (opcional)" : "Digite uma senha"}
                          data-testid="input-password"
                          {...field} 
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="role"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Função</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger data-testid="select-role">
                            <SelectValue placeholder="Selecione uma função" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="admin">Administrador</SelectItem>
                          <SelectItem value="gestor_cliente">Gestor de Cliente</SelectItem>
                          <SelectItem value="supervisor_site">Supervisor de Local</SelectItem>
                          <SelectItem value="operador">Operador</SelectItem>
                          <SelectItem value="auditor">Auditor</SelectItem>
                        </SelectContent>
                      </Select>
                    </FormItem>
                  )}
                />

                <div className="flex justify-end space-x-2">
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setIsCreateDialogOpen(false)}
                    data-testid="button-cancel"
                  >
                    Cancelar
                  </Button>
                  <Button 
                    type="submit" 
                    disabled={createUserMutation.isPending || updateUserMutation.isPending}
                    data-testid="button-save"
                  >
                    {(createUserMutation.isPending || updateUserMutation.isPending) ? 'Salvando...' : 'Salvar'}
                  </Button>
                </div>
              </form>
            </Form>
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <div>
              <CardTitle>Usuários OPUS Cadastrados</CardTitle>
              <CardDescription>
                Total de {filteredUsers.length} funcionário(s) OPUS
              </CardDescription>
            </div>
            <Input
              placeholder="Buscar por nome, email ou username..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="max-w-sm"
              data-testid="input-search"
            />
          </div>
        </CardHeader>
        <CardContent>
          {filteredUsers.length === 0 ? (
            <div className="text-center py-12">
              <Users className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold mb-2">Nenhum usuário encontrado</h3>
              <p className="text-muted-foreground">
                {searchTerm ? 'Tente ajustar sua busca' : 'Crie o primeiro usuário OPUS'}
              </p>
            </div>
          ) : (
            <div className="grid gap-4">
              {filteredUsers.map((user: User) => (
                <Card key={user.id} className="border-l-4 border-l-primary">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                          <CardTitle className="text-lg">{user.name}</CardTitle>
                          {getCustomRoleName(user) ? (
                            <Badge variant={getRoleBadgeColor(user)}>
                              {getRoleLabel(user)}
                            </Badge>
                          ) : (
                            <Badge variant="destructive" className="animate-pulse">
                              ⚠️ SEM PERFIL
                            </Badge>
                          )}
                          {!user.isActive && (
                            <Badge variant="destructive">Inativo</Badge>
                          )}
                        </div>
                        <CardDescription>
                          <div className="space-y-1">
                            <div><strong>Username:</strong> {user.username}</div>
                            <div><strong>Email:</strong> {user.email}</div>
                          </div>
                        </CardDescription>
                      </div>
                      <div className="flex gap-1">
                        <Button
                          variant="outline"
                          size="icon"
                          className="h-8 w-8"
                          onClick={() => handleEdit(user)}
                          data-testid={`button-edit-${user.id}`}
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="outline"
                          size="icon"
                          className="h-8 w-8"
                          onClick={() => {
                            if (confirm(`Resetar senha de ${user.name}? Uma nova senha será gerada e exibida.`)) {
                              resetPasswordMutation.mutate(user.id);
                            }
                          }}
                          disabled={resetPasswordMutation.isPending}
                          data-testid={`button-reset-password-${user.id}`}
                          title="Resetar Senha"
                        >
                          <KeyRound className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="outline"
                          size="icon"
                          className={`h-8 w-8 ${user.isActive ? 'text-destructive hover:bg-destructive hover:text-destructive-foreground' : 'text-green-600 hover:bg-green-600 hover:text-white'}`}
                          onClick={() => toggleUserStatusMutation.mutate({ 
                            id: user.id, 
                            isActive: !user.isActive 
                          })}
                          data-testid={`button-toggle-${user.id}`}
                          title={user.isActive ? 'Desativar' : 'Ativar'}
                        >
                          {user.isActive ? <Trash2 className="h-4 w-4" /> : <Plus className="h-4 w-4" />}
                        </Button>
                      </div>
                    </div>
                  </CardHeader>
                </Card>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}