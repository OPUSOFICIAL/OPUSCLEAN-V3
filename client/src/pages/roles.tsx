import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Checkbox } from '@/components/ui/checkbox';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Form, FormControl, FormField, FormItem, FormLabel } from '@/components/ui/form';
import { Textarea } from '@/components/ui/textarea';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useToast } from '@/hooks/use-toast';
import { apiRequest } from '@/lib/queryClient';
import { Users, Shield, Plus, Edit, Trash2, Settings, LayoutDashboard, FileText, MapPin, BarChart3, ClipboardCheck, QrCode, Map, Thermometer, Building2, UserCog, Settings2, Eye, CheckCircle2, XCircle } from 'lucide-react';
import usePermissions, { PermissionKey } from '@/hooks/usePermissions';
import type { CustomRole } from '@/hooks/usePermissions';
import { ModernPageHeader } from '@/components/ui/modern-page-header';
import { ModernCard } from '@/components/ui/modern-card';
import { useModuleTheme } from '@/hooks/use-module-theme';

const createRoleSchema = z.object({
  name: z.string().min(1, 'Nome é obrigatório'),
  description: z.string().optional(),
  permissions: z.array(z.string()).min(1, 'Selecione pelo menos uma permissão'),
});

type CreateRoleForm = z.infer<typeof createRoleSchema>;

export default function Roles() {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const { availablePermissions, can } = usePermissions();
  const theme = useModuleTheme();
  const [searchTerm, setSearchTerm] = useState('');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingRole, setEditingRole] = useState<CustomRole | null>(null);

  const form = useForm<CreateRoleForm>({
    resolver: zodResolver(createRoleSchema),
    defaultValues: {
      name: '',
      description: '',
      permissions: [],
    },
  });

  // Verificar se o usuário pode gerenciar roles
  if (!can.manageRoles()) {
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
              Você não tem permissão para acessar o gerenciamento de funções.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const { data: roles = [], isLoading } = useQuery<CustomRole[]>({
    queryKey: ['/api/roles'],
  });

  const createRoleMutation = useMutation({
    mutationFn: async (data: CreateRoleForm) => {
      await apiRequest('POST', '/api/roles', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/roles'] });
      setIsCreateDialogOpen(false);
      setEditingRole(null);
      form.reset();
      toast({
        title: 'Sucesso',
        description: 'Função criada com sucesso!',
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

  const updateRoleMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: CreateRoleForm }) => {
      await apiRequest('PATCH', `/api/roles/${id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/roles'] });
      setIsCreateDialogOpen(false);
      setEditingRole(null);
      form.reset();
      toast({
        title: 'Sucesso',
        description: 'Função atualizada com sucesso!',
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

  const deleteRoleMutation = useMutation({
    mutationFn: async (roleId: string) => {
      await apiRequest('DELETE', `/api/roles/${roleId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/roles'] });
      toast({
        title: 'Sucesso',
        description: 'Função excluída com sucesso!',
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

  const filteredRoles = roles.filter((role: CustomRole) =>
    role.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    role.description?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleEdit = (role: CustomRole) => {
    setEditingRole(role);
    form.reset({
      name: role.name,
      description: role.description || '',
      permissions: role.permissions,
    });
    setIsCreateDialogOpen(true);
  };

  const handleSubmit = (data: CreateRoleForm) => {
    if (editingRole) {
      updateRoleMutation.mutate({ id: editingRole.id, data });
    } else {
      createRoleMutation.mutate(data);
    }
  };

  // Agrupar permissões por categoria
  const groupedPermissions = availablePermissions.reduce((acc, permission) => {
    if (!acc[permission.category]) {
      acc[permission.category] = [];
    }
    acc[permission.category].push(permission);
    return acc;
  }, {} as Record<string, typeof availablePermissions>);

  // Mapear áreas acessíveis com ícones
  const areaAccessMap: Record<string, { label: string; icon: any; viewPerm: string }> = {
    dashboard: { label: 'Dashboard', icon: LayoutDashboard, viewPerm: 'dashboard_view' },
    workorders: { label: 'Ordens de Serviço', icon: FileText, viewPerm: 'workorders_view' },
    schedule: { label: 'Plano de Limpeza', icon: ClipboardCheck, viewPerm: 'schedule_view' },
    checklists: { label: 'Checklists', icon: ClipboardCheck, viewPerm: 'checklists_view' },
    qrcodes: { label: 'QR Codes', icon: QrCode, viewPerm: 'qrcodes_view' },
    floorplan: { label: 'Planta dos Locais', icon: Map, viewPerm: 'floor_plan_view' },
    heatmap: { label: 'Mapa de Calor', icon: Thermometer, viewPerm: 'heatmap_view' },
    sites: { label: 'Locais', icon: Building2, viewPerm: 'sites_view' },
    reports: { label: 'Relatórios', icon: BarChart3, viewPerm: 'reports_view' },
    settings: { label: 'Configurações', icon: Settings2, viewPerm: 'service_settings_view' },
    users: { label: 'Usuários', icon: UserCog, viewPerm: 'users_view' },
  };

  const getAccessibleAreas = (permissions: string[]) => {
    return Object.entries(areaAccessMap)
      .filter(([_, area]) => permissions.includes(area.viewPerm))
      .map(([key, area]) => ({ key, ...area }));
  };

  if (isLoading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="text-muted-foreground">Carregando...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-gray-50/30 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <ModernPageHeader 
          title="Funções" 
          description="Gerencie funções e permissões personalizadas" 
          icon={Shield}
          actions={
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button 
                  onClick={() => {
                    setEditingRole(null);
                    form.reset();
                  }}
                  className={theme.buttons.primary}
                  style={theme.buttons.primaryStyle}
                  data-testid="button-create-role"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Nova Função
                </Button>
              </DialogTrigger>
            <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle>
                  {editingRole ? 'Editar Função' : 'Nova Função'}
                </DialogTitle>
                <DialogDescription>
                  {editingRole ? 'Edite os dados da função' : 'Crie uma nova função com permissões específicas'}
                </DialogDescription>
              </DialogHeader>

              <Form {...form}>
                <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <FormField
                      control={form.control}
                      name="name"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Nome da Função</FormLabel>
                          <FormControl>
                            <Input 
                              placeholder="Ex: Supervisor, Operador Avançado"
                              data-testid="input-role-name"
                              {...field} 
                            />
                          </FormControl>
                        </FormItem>
                      )}
                    />
                    <FormField
                      control={form.control}
                      name="description"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel>Descrição</FormLabel>
                          <FormControl>
                            <Textarea 
                              placeholder="Descreva as responsabilidades desta função"
                              className="resize-none"
                              data-testid="input-role-description"
                              {...field}
                            />
                          </FormControl>
                        </FormItem>
                      )}
                    />
                  </div>

                  <div>
                    <FormLabel className="text-base font-medium mb-4 block">
                      Permissões
                    </FormLabel>
                    <div className="space-y-4">
                      {Object.entries(groupedPermissions).map(([category, permissions]) => (
                        <Card key={category}>
                          <CardHeader className="pb-3">
                            <CardTitle className="text-sm font-medium">{category}</CardTitle>
                          </CardHeader>
                          <CardContent className="space-y-3">
                            {permissions.map((permission) => (
                              <FormField
                                key={permission.key}
                                control={form.control}
                                name="permissions"
                                render={({ field }) => (
                                  <FormItem className="flex items-center space-x-3 space-y-0">
                                    <FormControl>
                                      <Checkbox
                                        checked={field.value.includes(permission.key)}
                                        onCheckedChange={(checked) => {
                                          if (checked) {
                                            field.onChange([...field.value, permission.key]);
                                          } else {
                                            field.onChange(
                                              field.value.filter((value) => value !== permission.key)
                                            );
                                          }
                                        }}
                                        data-testid={`checkbox-permission-${permission.key}`}
                                      />
                                    </FormControl>
                                    <FormLabel className="text-sm font-normal">
                                      {permission.label}
                                    </FormLabel>
                                  </FormItem>
                                )}
                              />
                            ))}
                          </CardContent>
                        </Card>
                      ))}
                    </div>
                  </div>

                  <div className="flex justify-end space-x-2">
                    <Button 
                      type="button" 
                      variant="outline" 
                      onClick={() => setIsCreateDialogOpen(false)}
                      data-testid="button-cancel-role"
                    >
                      Cancelar
                    </Button>
                    <Button 
                      type="submit" 
                      disabled={createRoleMutation.isPending || updateRoleMutation.isPending}
                      data-testid="button-save-role"
                    >
                      {(createRoleMutation.isPending || updateRoleMutation.isPending) ? 'Salvando...' : 'Salvar'}
                    </Button>
                  </div>
                </form>
              </Form>
            </DialogContent>
          </Dialog>
          }
        />

        <ModernCard variant="gradient">
          <CardHeader>
            <div className="flex justify-between items-center">
              <div>
                <CardTitle>Funções Cadastradas</CardTitle>
                <CardDescription>
                  Total de {filteredRoles.length} função(ões)
                </CardDescription>
              </div>
              <Input
                placeholder="Buscar por nome ou descrição..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="max-w-sm"
                data-testid="input-search-roles"
              />
            </div>
          </CardHeader>
          <CardContent>
            {filteredRoles.length === 0 ? (
              <div className="text-center py-12">
                <Users className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                <h3 className="text-lg font-semibold mb-2">Nenhuma função encontrada</h3>
                <p className="text-muted-foreground">
                  {searchTerm ? 'Tente ajustar sua busca' : 'Crie a primeira função personalizada'}
                </p>
              </div>
            ) : (
              <div className="grid gap-4">
                {filteredRoles.map((role: CustomRole) => (
                  <ModernCard key={role.id} variant="gradient">
                    <CardHeader>
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <CardTitle className="text-lg">{role.name}</CardTitle>
                            {role.isSystemRole && (
                              <Badge variant="secondary">Sistema</Badge>
                            )}
                            {!role.isActive && (
                              <Badge variant="destructive">Inativo</Badge>
                            )}
                            {role.name === 'Operador' && (
                              <Badge variant="outline" className="bg-blue-50 dark:bg-blue-950 text-blue-700 dark:text-blue-300 border-blue-200 dark:border-blue-800">
                                📱 Acesso Mobile
                              </Badge>
                            )}
                          </div>
                          {role.description && (
                            <CardDescription className="mt-2">
                              {role.description}
                            </CardDescription>
                          )}
                          {role.name === 'Operador' && (
                            <div className="mt-2 p-2 bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800 rounded-md">
                              <p className="text-xs text-blue-700 dark:text-blue-300">
                                ℹ️ Este perfil é exclusivo para <strong>aplicativo mobile</strong>. Operadores não acessam o sistema web administrativo, apenas o app mobile para executar tarefas.
                              </p>
                            </div>
                          )}
                          
                          {/* Áreas Acessíveis */}
                          <div className="mt-4 space-y-2">
                            <span className="text-sm font-medium text-foreground">
                              Áreas Acessíveis ({getAccessibleAreas(role.permissions).length}):
                            </span>
                            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                              {getAccessibleAreas(role.permissions).map((area) => {
                                const Icon = area.icon;
                                return (
                                  <div 
                                    key={area.key}
                                    className="flex items-center gap-2 px-3 py-2 rounded-md bg-primary/5 border border-primary/20 text-sm"
                                  >
                                    <Icon className="h-4 w-4 text-primary flex-shrink-0" />
                                    <span className="text-foreground text-xs">{area.label}</span>
                                  </div>
                                );
                              })}
                            </div>
                          </div>

                          {/* Total de Permissões */}
                          <div className="mt-4 pt-3 border-t">
                            <div className="flex items-center justify-between text-sm">
                              <span className="text-muted-foreground">
                                Total de permissões:
                              </span>
                              <Badge variant="secondary">
                                {role.permissions.length}
                              </Badge>
                            </div>
                          </div>
                        </div>
                        <div className="flex space-x-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleEdit(role)}
                            data-testid={`button-edit-role-${role.id}`}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          {!role.isSystemRole && (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => deleteRoleMutation.mutate(role.id)}
                              disabled={deleteRoleMutation.isPending}
                              data-testid={`button-delete-role-${role.id}`}
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          )}
                        </div>
                      </div>
                    </CardHeader>
                  </ModernCard>
                ))}
              </div>
            )}
          </CardContent>
        </ModernCard>
      </div>
    </div>
  );
}