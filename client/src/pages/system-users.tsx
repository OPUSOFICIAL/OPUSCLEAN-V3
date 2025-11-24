import { useState, useEffect } from 'react';
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
import { useModuleTheme } from '@/hooks/use-module-theme';
import { Checkbox } from '@/components/ui/checkbox';
import { useAuth } from '@/hooks/useAuth';
import { useCacheInvalidation } from '@/hooks/use-cache-invalidation';

const createUserSchema = z.object({
  username: z.string().min(1, 'Username é obrigatório'),
  email: z.string().email('Email inválido'),
  password: z.string().refine(
    (val) => val === '' || val.length >= 6,
    'Senha deve ter no mínimo 6 caracteres'
  ),
  name: z.string().min(1, 'Nome é obrigatório'),
  customRoleId: z.string().min(1, 'Função é obrigatória'),
  modules: z.array(z.enum(['clean', 'maintenance'])).min(1, 'Selecione pelo menos um módulo'),
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
  modules?: ('clean' | 'maintenance')[];
  createdAt: string;
  updatedAt: string;
};

export default function SystemUsers() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const cache = useCacheInvalidation();
  const { can } = usePermissions();
  const { currentModule } = useModule();
  const theme = useModuleTheme();
  const { user: currentUser } = useAuth();
  const [searchTerm, setSearchTerm] = useState('');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [selectedCustomerIds, setSelectedCustomerIds] = useState<string[]>([]);
  const [hasInitializedCustomers, setHasInitializedCustomers] = useState(false);

  const form = useForm<CreateUserForm>({
    resolver: zodResolver(createUserSchema),
    defaultValues: {
      username: '',
      email: '',
      password: '',
      name: '',
      customRoleId: '',
      modules: ['clean', 'maintenance'],
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
  const userCompanyId = currentUser?.companyId || "company-admin-default";
  
  const { data: users = [], isLoading } = useQuery<User[]>({
    queryKey: ['/api/system-users'],
  });

  // Buscar todos os clientes disponíveis
  const { data: availableCustomers = [] } = useQuery({
    queryKey: ['/api/companies', userCompanyId, 'customers'],
    enabled: isCreateDialogOpen,
  });

  // Buscar clientes permitidos do usuário em edição
  const { data: allowedCustomers = [] } = useQuery({
    queryKey: ['/api/system-users', editingUser?.id, 'allowed-customers'],
    enabled: !!editingUser?.id && isCreateDialogOpen,
  });

  // Buscar custom roles de sistema
  const { data: systemRoles = [] } = useQuery({
    queryKey: ['/api/roles?isSystemRole=true'],
  });

  const createUserMutation = useMutation({
    mutationFn: async (data: CreateUserForm) => {
      await apiRequest('POST', '/api/system-users', {
        ...data,
        userType: 'opus_user',
        companyId: userCompanyId,
      });
    },
    onSuccess: () => {
      cache.invalidateUsers();
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
      cache.invalidateUsers();
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
      cache.invalidateUsers();
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
      cache.invalidateUsers();
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

  const updateAllowedCustomersMutation = useMutation({
    mutationFn: async ({ userId, customerIds }: { userId: string; customerIds: string[] }) => {
      await apiRequest('PUT', `/api/system-users/${userId}/allowed-customers`, { customerIds });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/system-users'] });
    },
  });

  // Carregar clientes permitidos quando abrindo dialog de edição
  useEffect(() => {
    if (!isCreateDialogOpen) {
      setHasInitializedCustomers(false);
      return;
    }
    
    // Só inicializar UMA VEZ quando o dialog abre
    if (hasInitializedCustomers) {
      return;
    }
    
    const allowedCustomersArray = Array.isArray(allowedCustomers) ? allowedCustomers : [];
    const availableCustomersArray = Array.isArray(availableCustomers) ? availableCustomers : [];
    
    if (editingUser && allowedCustomersArray.length > 0) {
      setSelectedCustomerIds((allowedCustomersArray as any[]).map((c: any) => c.id));
    } else if (!editingUser) {
      // Ao criar novo usuário, selecionar todos os clientes por padrão
      setSelectedCustomerIds((availableCustomersArray as any[]).map((c: any) => c.id));
    }
    
    setHasInitializedCustomers(true);
  }, [editingUser, allowedCustomers, isCreateDialogOpen, availableCustomers, hasInitializedCustomers]);

  const filteredUsers = users.filter((user: User) =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.username.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleEdit = (user: User & { customRoles?: any[] }) => {
    setEditingUser(user);
    
    // Pegar a custom role do usuário
    const userCustomRoleId = user.customRoles?.[0]?.roleId || '';
    
    form.reset({
      username: user.username,
      email: user.email,
      name: user.name,
      customRoleId: userCustomRoleId,
      modules: user.modules || ['clean', 'maintenance'],
      password: '', // Não pré-carregar senha
    });
    setIsCreateDialogOpen(true);
  };

  const handleSubmit = async (data: CreateUserForm) => {
    try {
      if (editingUser) {
        // Remover password se estiver vazia na edição
        const updateData = data.password ? data : { ...data, password: undefined };
        await updateUserMutation.mutateAsync({ id: editingUser.id, data: updateData });
        
        // Atualizar clientes permitidos
        await updateAllowedCustomersMutation.mutateAsync({ 
          userId: editingUser.id, 
          customerIds: selectedCustomerIds 
        });
      } else {
        // Criar usuário primeiro
        const newUser = await createUserMutation.mutateAsync(data);
        
        // Salvar clientes permitidos
        // Aguardar um pouco para garantir que o usuário foi criado
        setTimeout(async () => {
          const createdUsers = await queryClient.getQueryData(['/api/system-users']) as User[];
          const createdUser = createdUsers?.find((u: User) => u.email === data.email);
          if (createdUser) {
            await updateAllowedCustomersMutation.mutateAsync({ 
              userId: createdUser.id, 
              customerIds: selectedCustomerIds 
            });
          }
        }, 500);
      }
      
      setIsCreateDialogOpen(false);
      setEditingUser(null);
      form.reset();
      setSelectedCustomerIds([]);
      setHasInitializedCustomers(false);
    } catch (error) {
      // Erro já tratado pelas mutations
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
            Usuários do Sistema
          </h1>
          <p className="text-muted-foreground mt-2">
            Gerenciar usuários com acesso ao sistema de gerenciamento
          </p>
        </div>

        <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
          <DialogTrigger asChild>
            <Button 
              variant="default"
              onClick={() => {
                setEditingUser(null);
                form.reset();
              }}
              className={theme.buttons.primary}
              style={theme.buttons.primaryStyle}
              data-testid="button-create-system-user"
            >
              <Plus className="h-4 w-4 mr-2" />
              Novo Usuário do Sistema
            </Button>
          </DialogTrigger>
          <DialogContent className="max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                {editingUser ? 'Editar Usuário do Sistema' : 'Novo Usuário do Sistema'}
              </DialogTitle>
              <DialogDescription>
                {editingUser ? 'Edite os dados do usuário' : 'Crie um novo usuário com acesso ao sistema'}
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
                  name="customRoleId"
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
                          {(systemRoles as any[]).map((role: any) => (
                            <SelectItem key={role.id} value={role.id}>
                              {role.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                      <p className="text-sm text-muted-foreground">
                        Selecione a função do usuário no sistema
                      </p>
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="modules"
                  render={() => (
                    <FormItem>
                      <FormLabel>Módulos Disponíveis</FormLabel>
                      <div className="space-y-2">
                        <FormField
                          control={form.control}
                          name="modules"
                          render={({ field }) => (
                            <FormItem className="flex items-center space-x-2 space-y-0">
                              <FormControl>
                                <Checkbox
                                  checked={field.value?.includes('clean')}
                                  onCheckedChange={(checked) => {
                                    const currentModules = field.value || [];
                                    if (checked) {
                                      field.onChange([...currentModules.filter((m: string) => m !== 'clean'), 'clean']);
                                    } else {
                                      field.onChange(currentModules.filter((m: string) => m !== 'clean'));
                                    }
                                  }}
                                  data-testid="checkbox-module-clean"
                                />
                              </FormControl>
                              <FormLabel className="font-normal cursor-pointer">
                                Clean (Limpeza)
                              </FormLabel>
                            </FormItem>
                          )}
                        />
                        <FormField
                          control={form.control}
                          name="modules"
                          render={({ field }) => (
                            <FormItem className="flex items-center space-x-2 space-y-0">
                              <FormControl>
                                <Checkbox
                                  checked={field.value?.includes('maintenance')}
                                  onCheckedChange={(checked) => {
                                    const currentModules = field.value || [];
                                    if (checked) {
                                      field.onChange([...currentModules.filter((m: string) => m !== 'maintenance'), 'maintenance']);
                                    } else {
                                      field.onChange(currentModules.filter((m: string) => m !== 'maintenance'));
                                    }
                                  }}
                                  data-testid="checkbox-module-maintenance"
                                />
                              </FormControl>
                              <FormLabel className="font-normal cursor-pointer">
                                Manutenção
                              </FormLabel>
                            </FormItem>
                          )}
                        />
                      </div>
                      <p className="text-sm text-muted-foreground mt-2">
                        Selecione os módulos que este usuário pode acessar
                      </p>
                    </FormItem>
                  )}
                />

                {/* Aviso se função não estiver selecionada */}
                {!form.watch('customRoleId') && (
                  <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-md">
                    <p className="text-sm text-destructive font-medium">
                      ⚠️ Função é obrigatória - Todo usuário do sistema deve ter uma função atribuída.
                    </p>
                  </div>
                )}

                {/* Clientes Permitidos - sempre exibir */}
                <div className="space-y-3 border-t pt-4">
                    <div>
                      <FormLabel>Clientes Permitidos</FormLabel>
                      <p className="text-sm text-muted-foreground mt-1">
                        Selecione quais clientes este usuário pode acessar
                      </p>
                    </div>
                    
                    <div className="space-y-2 max-h-48 overflow-y-auto border rounded-md p-3">
                      {(availableCustomers as any[]).map((customer: any) => (
                        <div key={customer.id} className="flex items-center space-x-2">
                          <Checkbox
                            checked={selectedCustomerIds.includes(customer.id)}
                            onCheckedChange={(checked) => {
                              if (checked) {
                                setSelectedCustomerIds([...selectedCustomerIds, customer.id]);
                              } else {
                                setSelectedCustomerIds(selectedCustomerIds.filter(id => id !== customer.id));
                              }
                            }}
                            data-testid={`checkbox-customer-${customer.id}`}
                          />
                          <label className="text-sm font-normal cursor-pointer flex-1">
                            {customer.name}
                          </label>
                        </div>
                      ))}
                    </div>

                    {selectedCustomerIds.length === 0 && (
                      <p className="text-sm text-destructive">
                        Atenção: Selecione pelo menos um cliente
                      </p>
                    )}
                  </div>

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
                    variant="default"
                    disabled={createUserMutation.isPending || updateUserMutation.isPending || !form.watch('customRoleId')}
                    data-testid="button-save"
                    className={theme.buttons.primary}
                    style={theme.buttons.primaryStyle}
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
              <CardTitle>Usuários do Sistema Cadastrados</CardTitle>
              <CardDescription>
                Total de {filteredUsers.length} usuário(s) do sistema
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
                {searchTerm ? 'Tente ajustar sua busca' : 'Crie o primeiro usuário do sistema'}
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
                            {user.modules && user.modules.length > 0 && (
                              <div className="flex gap-1 mt-2">
                                {user.modules.includes('clean') && (
                                  <Badge variant="secondary" className="text-xs">
                                    Clean
                                  </Badge>
                                )}
                                {user.modules.includes('maintenance') && (
                                  <Badge variant="secondary" className="text-xs">
                                    Manutenção
                                  </Badge>
                                )}
                              </div>
                            )}
                            {(user as any).allowedCustomers && (user as any).allowedCustomers.length > 0 && (
                              <div className="mt-2">
                                <div className="text-xs text-muted-foreground mb-1">Clientes com acesso:</div>
                                <div className="flex flex-wrap gap-1">
                                  {(user as any).allowedCustomers.map((customer: any) => (
                                    <Badge 
                                      key={customer.id} 
                                      variant="outline"
                                      className="text-xs"
                                    >
                                      {customer.name}
                                    </Badge>
                                  ))}
                                </div>
                              </div>
                            )}
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