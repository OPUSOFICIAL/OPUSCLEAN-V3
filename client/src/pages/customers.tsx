import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { useLocation } from "wouter";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Plus, Edit, Trash2, Search, Users, Building2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ModernCard } from "@/components/ui/modern-card";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Checkbox } from "@/components/ui/checkbox";
import { useToast } from "@/hooks/use-toast";
import { useModuleTheme } from "@/hooks/use-module-theme";
import { queryClient, apiRequest } from "@/lib/queryClient";
import type { Customer, InsertCustomer } from "@shared/schema";

const customerFormSchema = z.object({
  name: z.string().min(2, "Nome deve ter pelo menos 2 caracteres"),
  email: z.string().email("E-mail inválido").optional().or(z.literal("")),
  phone: z.string().optional(),
  document: z.string().optional(),
  address: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  zipCode: z.string().optional(),
  contactPerson: z.string().optional(),
  notes: z.string().optional(),
  modules: z.array(z.enum(['clean', 'maintenance'])).min(1, "Selecione pelo menos um módulo"),
});

type CustomerFormData = z.infer<typeof customerFormSchema>;

interface CustomersPageProps {
  companyId: string;
}

export default function CustomersPage({ companyId }: CustomersPageProps) {
  const [location, navigate] = useLocation();
  const { toast } = useToast();
  const theme = useModuleTheme();
  const [searchTerm, setSearchTerm] = useState("");
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState<Customer | null>(null);

  // Company ID comes from props

  const { data: customers = [], isLoading } = useQuery<Customer[]>({
    queryKey: ["/api/companies", companyId, "customers"],
  });

  const createCustomerMutation = useMutation({
    mutationFn: async (data: CustomerFormData) => {
      return await apiRequest("POST", `/api/companies/${companyId}/customers`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/companies", companyId, "customers"] });
      setIsCreateDialogOpen(false);
      toast({ title: "Cliente criado com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao criar cliente", variant: "destructive" });
    },
  });

  const updateCustomerMutation = useMutation({
    mutationFn: async (data: { id: string } & Partial<CustomerFormData>) => {
      const { id, ...updateData } = data;
      return await apiRequest("PUT", `/api/customers/${id}`, updateData);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/companies", companyId, "customers"] });
      setIsEditDialogOpen(false);
      setEditingCustomer(null);
      toast({ title: "Cliente atualizado com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao atualizar cliente", variant: "destructive" });
    },
  });

  const deleteCustomerMutation = useMutation({
    mutationFn: async (customerId: string) => {
      return await apiRequest("DELETE", `/api/customers/${customerId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/companies", companyId, "customers"] });
      toast({ title: "Cliente removido com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao remover cliente", variant: "destructive" });
    },
  });

  const createForm = useForm<CustomerFormData>({
    resolver: zodResolver(customerFormSchema),
    defaultValues: {
      name: "",
      email: "",
      phone: "",
      document: "",
      address: "",
      city: "",
      state: "",
      zipCode: "",
      contactPerson: "",
      notes: "",
      modules: ['clean'],
    },
  });

  const editForm = useForm<CustomerFormData>({
    resolver: zodResolver(customerFormSchema),
    defaultValues: {
      name: "",
      email: "",
      phone: "",
      document: "",
      address: "",
      city: "",
      state: "",
      zipCode: "",
      contactPerson: "",
      notes: "",
      modules: [],
    },
  });

  const handleCreateCustomer = (data: CustomerFormData) => {
    createCustomerMutation.mutate(data);
  };

  const handleEditCustomer = (customer: Customer) => {
    setEditingCustomer(customer);
    editForm.reset({
      name: customer.name,
      email: customer.email || "",
      phone: customer.phone || "",
      document: customer.document || "",
      address: customer.address || "",
      city: customer.city || "",
      state: customer.state || "",
      zipCode: customer.zipCode || "",
      contactPerson: customer.contactPerson || "",
      notes: customer.notes || "",
      modules: (customer.modules || ['clean']) as ('clean' | 'maintenance')[],
    });
    setIsEditDialogOpen(true);
  };

  const handleUpdateCustomer = (data: CustomerFormData) => {
    if (!editingCustomer) return;
    updateCustomerMutation.mutate({ id: editingCustomer.id, ...data });
  };

  const handleDeleteCustomer = (customerId: string) => {
    if (confirm("Tem certeza que deseja remover este cliente?")) {
      deleteCustomerMutation.mutate(customerId);
    }
  };

  const getModulesBadges = (customer: Customer) => {
    const modules = customer.modules || [];
    
    return (
      <div className="flex flex-wrap gap-1">
        {modules.includes('clean') && (
          <Badge className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200" data-testid={`badge-module-clean-${customer.id}`}>
            Clean
          </Badge>
        )}
        {modules.includes('maintenance') && (
          <Badge className="bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200" data-testid={`badge-module-maintenance-${customer.id}`}>
            Manutenção
          </Badge>
        )}
      </div>
    );
  };

  const filteredCustomers = customers
    .filter(customer => customer.isActive) // Mostrar apenas clientes ativos
    .filter(customer =>
      customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (customer.email && customer.email.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (customer.document && customer.document.includes(searchTerm))
    );

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-white via-gray-50/30 to-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="animate-pulse space-y-4">
            <div className="h-8 bg-muted rounded w-1/3"></div>
            <div className="h-64 bg-muted rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-white via-gray-50/30 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="space-y-3 md:space-y-4">
          {/* Header */}
          <ModernPageHeader 
            title="Clientes" 
            description="Gerencie seus clientes" 
            icon={Building2}
            actions={
              <Button 
                onClick={() => setIsCreateDialogOpen(true)}
                className={theme.buttons.primary}
                data-testid="button-create-customer"
              >
                <Plus className="w-4 h-4 mr-2" />
                Novo Cliente
              </Button>
            }
          />

          {/* Search */}
          <ModernCard variant="glass">
            <CardContent className="pt-6">
              <div className="relative max-w-md">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Buscar clientes..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                  data-testid="input-search-customers"
                />
              </div>
            </CardContent>
          </ModernCard>

          {/* Customers Table */}
          <ModernCard variant="glass">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Building2 className="w-5 h-5" />
            <span>Lista de Clientes ({filteredCustomers.length})</span>
          </CardTitle>
          <CardDescription>
            Gerencie informações dos seus clientes
          </CardDescription>
        </CardHeader>
        <CardContent>
          {filteredCustomers.length === 0 ? (
            <div className="text-center py-12">
              <Users className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-muted-foreground mb-2">
                {searchTerm ? "Nenhum cliente encontrado" : "Nenhum cliente cadastrado"}
              </h3>
              <p className="text-sm text-muted-foreground mb-4">
                {searchTerm 
                  ? "Tente buscar com outros termos" 
                  : "Crie o primeiro cliente para começar"
                }
              </p>
              {!searchTerm && (
                <Button 
                  onClick={() => setIsCreateDialogOpen(true)}
                  className={theme.buttons.primary}
                  data-testid="button-create-first-customer"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Criar Primeiro Cliente
                </Button>
              )}
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Nome</TableHead>
                  <TableHead>E-mail</TableHead>
                  <TableHead>Telefone</TableHead>
                  <TableHead>Documento</TableHead>
                  <TableHead>Cidade</TableHead>
                  <TableHead>Módulos</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Ações</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredCustomers.map((customer) => (
                  <TableRow key={customer.id}>
                    <TableCell className="font-medium">{customer.name}</TableCell>
                    <TableCell>{customer.email || "-"}</TableCell>
                    <TableCell>{customer.phone || "-"}</TableCell>
                    <TableCell>{customer.document || "-"}</TableCell>
                    <TableCell>{customer.city || "-"}</TableCell>
                    <TableCell>{getModulesBadges(customer)}</TableCell>
                    <TableCell>
                      {customer.isActive ? (
                        <Badge className="bg-chart-2/10 text-chart-2">Ativo</Badge>
                      ) : (
                        <Badge variant="outline">Inativo</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center space-x-2">
                        <Button 
                          variant="ghost" 
                          size="sm"
                          onClick={() => handleEditCustomer(customer)}
                          data-testid={`button-edit-customer-${customer.id}`}
                        >
                          <Edit className="w-4 h-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="sm"
                          onClick={() => handleDeleteCustomer(customer.id)}
                          data-testid={`button-delete-customer-${customer.id}`}
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </ModernCard>

      {/* Create Customer Dialog */}
      <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
        <DialogContent className="max-w-lg max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Novo Cliente</DialogTitle>
            <DialogDescription>
              Preencha as informações do novo cliente
            </DialogDescription>
          </DialogHeader>
          <Form {...createForm}>
            <form onSubmit={createForm.handleSubmit(handleCreateCustomer)} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <FormField
                  control={createForm.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Nome *</FormLabel>
                      <FormControl>
                        <Input placeholder="Nome do cliente" {...field} data-testid="input-create-customer-name" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={createForm.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>E-mail</FormLabel>
                      <FormControl>
                        <Input type="email" placeholder="email@exemplo.com" {...field} data-testid="input-create-customer-email" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="phone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Telefone</FormLabel>
                      <FormControl>
                        <Input placeholder="(11) 99999-9999" {...field} data-testid="input-create-customer-phone" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="document"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>CPF/CNPJ</FormLabel>
                      <FormControl>
                        <Input placeholder="000.000.000-00" {...field} data-testid="input-create-customer-document" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="contactPerson"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Pessoa de Contato</FormLabel>
                      <FormControl>
                        <Input placeholder="Nome do contato" {...field} data-testid="input-create-customer-contact" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="address"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Endereço</FormLabel>
                      <FormControl>
                        <Input placeholder="Rua, número, bairro" {...field} data-testid="input-create-customer-address" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="city"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Cidade</FormLabel>
                      <FormControl>
                        <Input placeholder="São Paulo" {...field} data-testid="input-create-customer-city" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="state"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Estado</FormLabel>
                      <FormControl>
                        <Input placeholder="SP" {...field} data-testid="input-create-customer-state" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="zipCode"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>CEP</FormLabel>
                      <FormControl>
                        <Input placeholder="00000-000" {...field} data-testid="input-create-customer-zip" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="modules"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Módulos Disponíveis *</FormLabel>
                      <div className="flex items-center space-x-4 pt-2">
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            id="create-module-clean"
                            checked={field.value?.includes('clean')}
                            onCheckedChange={(checked) => {
                              const currentModules = field.value || [];
                              if (checked) {
                                field.onChange([...currentModules, 'clean']);
                              } else {
                                field.onChange(currentModules.filter((m: string) => m !== 'clean'));
                              }
                            }}
                            data-testid="checkbox-create-customer-module-clean"
                          />
                          <label htmlFor="create-module-clean" className="text-sm font-medium">
                            OPUS Clean
                          </label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            id="create-module-maintenance"
                            checked={field.value?.includes('maintenance')}
                            onCheckedChange={(checked) => {
                              const currentModules = field.value || [];
                              if (checked) {
                                field.onChange([...currentModules, 'maintenance']);
                              } else {
                                field.onChange(currentModules.filter((m: string) => m !== 'maintenance'));
                              }
                            }}
                            data-testid="checkbox-create-customer-module-maintenance"
                          />
                          <label htmlFor="create-module-maintenance" className="text-sm font-medium">
                            OPUS Manutenção
                          </label>
                        </div>
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={createForm.control}
                  name="notes"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Observações</FormLabel>
                      <FormControl>
                        <Textarea placeholder="Observações sobre o cliente" {...field} data-testid="textarea-create-customer-notes" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="flex justify-end space-x-2">
                <Button type="button" variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                  Cancelar
                </Button>
                <Button type="submit" disabled={createCustomerMutation.isPending} data-testid="button-submit-create-customer">
                  {createCustomerMutation.isPending ? "Criando..." : "Criar Cliente"}
                </Button>
              </div>
            </form>
          </Form>
        </DialogContent>
      </Dialog>

      {/* Edit Customer Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-lg max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Editar Cliente</DialogTitle>
            <DialogDescription>
              Altere as informações do cliente
            </DialogDescription>
          </DialogHeader>
          <Form {...editForm}>
            <form onSubmit={editForm.handleSubmit(handleUpdateCustomer)} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <FormField
                  control={editForm.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Nome *</FormLabel>
                      <FormControl>
                        <Input placeholder="Nome do cliente" {...field} data-testid="input-edit-customer-name" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={editForm.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>E-mail</FormLabel>
                      <FormControl>
                        <Input type="email" placeholder="email@exemplo.com" {...field} data-testid="input-edit-customer-email" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="phone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Telefone</FormLabel>
                      <FormControl>
                        <Input placeholder="(11) 99999-9999" {...field} data-testid="input-edit-customer-phone" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="document"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>CPF/CNPJ</FormLabel>
                      <FormControl>
                        <Input placeholder="000.000.000-00" {...field} data-testid="input-edit-customer-document" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="contactPerson"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Pessoa de Contato</FormLabel>
                      <FormControl>
                        <Input placeholder="Nome do contato" {...field} data-testid="input-edit-customer-contact" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="address"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Endereço</FormLabel>
                      <FormControl>
                        <Input placeholder="Rua, número, bairro" {...field} data-testid="input-edit-customer-address" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="city"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Cidade</FormLabel>
                      <FormControl>
                        <Input placeholder="São Paulo" {...field} data-testid="input-edit-customer-city" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="state"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Estado</FormLabel>
                      <FormControl>
                        <Input placeholder="SP" {...field} data-testid="input-edit-customer-state" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="zipCode"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>CEP</FormLabel>
                      <FormControl>
                        <Input placeholder="00000-000" {...field} data-testid="input-edit-customer-zip" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="modules"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Módulos Disponíveis *</FormLabel>
                      <div className="flex items-center space-x-4 pt-2">
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            id="edit-module-clean"
                            checked={field.value?.includes('clean')}
                            onCheckedChange={(checked) => {
                              const currentModules = field.value || [];
                              if (checked) {
                                field.onChange([...currentModules, 'clean']);
                              } else {
                                field.onChange(currentModules.filter((m: string) => m !== 'clean'));
                              }
                            }}
                            data-testid="checkbox-edit-customer-module-clean"
                          />
                          <label htmlFor="edit-module-clean" className="text-sm font-medium">
                            OPUS Clean
                          </label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <Checkbox
                            id="edit-module-maintenance"
                            checked={field.value?.includes('maintenance')}
                            onCheckedChange={(checked) => {
                              const currentModules = field.value || [];
                              if (checked) {
                                field.onChange([...currentModules, 'maintenance']);
                              } else {
                                field.onChange(currentModules.filter((m: string) => m !== 'maintenance'));
                              }
                            }}
                            data-testid="checkbox-edit-customer-module-maintenance"
                          />
                          <label htmlFor="edit-module-maintenance" className="text-sm font-medium">
                            OPUS Manutenção
                          </label>
                        </div>
                      </div>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={editForm.control}
                  name="notes"
                  render={({ field }) => (
                    <FormItem className="col-span-2">
                      <FormLabel>Observações</FormLabel>
                      <FormControl>
                        <Textarea placeholder="Observações sobre o cliente" {...field} data-testid="textarea-edit-customer-notes" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="flex justify-end space-x-2">
                <Button type="button" variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                  Cancelar
                </Button>
                <Button type="submit" disabled={updateCustomerMutation.isPending} data-testid="button-submit-edit-customer">
                  {updateCustomerMutation.isPending ? "Salvando..." : "Salvar Alterações"}
                </Button>
              </div>
            </form>
          </Form>
        </DialogContent>
      </Dialog>
        </div>
      </div>
    </div>
  );
}