import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useModule } from "@/contexts/ModuleContext";
import { Plus, Edit3, Trash2, List, FileText, Eye, Hash } from "lucide-react";
import { nanoid } from "nanoid";

interface ChecklistItem {
  id: string;
  type: 'text' | 'number' | 'photo' | 'checkbox';
  label: string;
  required: boolean;
  description?: string;
  validation?: {
    minLength?: number;
    maxLength?: number;
    minValue?: number;
    maxValue?: number;
    photoMinCount?: number;
    photoMaxCount?: number;
  };
}

interface MaintenanceChecklistTemplatesProps {
  customerId: string;
}

export default function MaintenanceChecklistTemplates({ customerId }: MaintenanceChecklistTemplatesProps) {
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [editingTemplate, setEditingTemplate] = useState<any>(null);
  
  // Form states
  const [templateForm, setTemplateForm] = useState({
    name: "",
    description: "",
    siteId: "none",
    zoneId: "none",
    equipmentId: "none",
    version: "1.0",
    items: [] as ChecklistItem[]
  });

  const [newItem, setNewItem] = useState<Partial<ChecklistItem>>({
    type: 'text',
    label: "",
    required: false,
    description: "",
    validation: {}
  });

  const { toast } = useToast();
  const { currentModule } = useModule();

  // Fetch customer data
  const { data: customer } = useQuery({
    queryKey: [`/api/customers/${customerId}`],
    enabled: !!customerId,
  });

  // Fetch templates
  const { data: templates, isLoading } = useQuery({
    queryKey: [`/api/customers/${customerId}/maintenance-checklist-templates`, { module: currentModule }],
    enabled: !!customerId,
  });

  // Fetch sites
  const { data: sites = [] } = useQuery({
    queryKey: [`/api/customers/${customerId}/sites`, { module: currentModule }],
    enabled: !!customerId,
  });

  // Fetch zones based on selected site
  const { data: zones = [] } = useQuery({
    queryKey: [`/api/sites/${templateForm.siteId}/zones`],
    enabled: templateForm.siteId !== "none" && !!templateForm.siteId,
  });

  // Fetch equipment based on site and zone
  const { data: equipment = [] } = useQuery({
    queryKey: [`/api/customers/${customerId}/equipment`, { 
      module: currentModule,
      siteId: templateForm.siteId !== "none" ? templateForm.siteId : undefined,
      zoneId: templateForm.zoneId !== "none" ? templateForm.zoneId : undefined,
    }],
    enabled: !!customerId,
  });

  const createTemplateMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("POST", "/api/maintenance-checklist-templates", data);
    },
    onSuccess: () => {
      toast({ title: "Template criado com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/maintenance-checklist-templates`] });
      setIsCreateDialogOpen(false);
      resetForm();
    },
    onError: () => {
      toast({ 
        title: "Erro ao criar template", 
        variant: "destructive" 
      });
    },
  });

  const updateTemplateMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("PUT", `/api/maintenance-checklist-templates/${data.id}`, data);
    },
    onSuccess: () => {
      toast({ title: "Template atualizado com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/maintenance-checklist-templates`] });
      setIsCreateDialogOpen(false);
      setEditingTemplate(null);
      resetForm();
    },
    onError: () => {
      toast({ 
        title: "Erro ao atualizar template", 
        variant: "destructive" 
      });
    },
  });

  const deleteTemplateMutation = useMutation({
    mutationFn: async (id: string) => {
      return await apiRequest("DELETE", `/api/maintenance-checklist-templates/${id}`);
    },
    onSuccess: () => {
      toast({ title: "Template excluído com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/maintenance-checklist-templates`] });
    },
    onError: () => {
      toast({ 
        title: "Erro ao excluir template", 
        variant: "destructive" 
      });
    },
  });

  const resetForm = () => {
    setTemplateForm({
      name: "",
      description: "",
      siteId: "none",
      zoneId: "none",
      equipmentId: "none",
      version: "1.0",
      items: []
    });
    setNewItem({
      type: 'text',
      label: "",
      required: false,
      description: "",
      validation: {}
    });
  };

  const handleAddItem = () => {
    if (!newItem.label) {
      toast({ 
        title: "Rótulo obrigatório", 
        description: "Digite um rótulo para o item", 
        variant: "destructive" 
      });
      return;
    }

    const item: ChecklistItem = {
      id: nanoid(),
      type: newItem.type || 'text',
      label: newItem.label,
      required: newItem.required || false,
      description: newItem.description,
      validation: newItem.validation
    };

    setTemplateForm(prev => ({
      ...prev,
      items: [...prev.items, item]
    }));

    // Reset new item
    setNewItem({
      type: 'text',
      label: "",
      required: false,
      description: "",
      validation: {}
    });
  };

  const handleRemoveItem = (itemId: string) => {
    setTemplateForm(prev => ({
      ...prev,
      items: prev.items.filter(item => item.id !== itemId)
    }));
  };

  const handleSubmit = () => {
    const companyId = (customer as any)?.companyId;
    if (!companyId || !templateForm.name) {
      toast({ 
        title: "Preencha todos os campos obrigatórios", 
        variant: "destructive" 
      });
      return;
    }

    if (templateForm.items.length === 0) {
      toast({
        title: "Itens obrigatórios",
        description: "Adicione pelo menos um item ao checklist.",
        variant: "destructive",
      });
      return;
    }

    const data = {
      companyId,
      customerId,
      name: templateForm.name,
      description: templateForm.description || null,
      siteId: templateForm.siteId === "none" ? null : templateForm.siteId,
      zoneId: templateForm.zoneId === "none" ? null : templateForm.zoneId,
      equipmentId: templateForm.equipmentId === "none" ? null : templateForm.equipmentId,
      version: templateForm.version,
      items: templateForm.items,
    };

    if (editingTemplate) {
      updateTemplateMutation.mutate({ ...data, id: editingTemplate.id });
    } else {
      createTemplateMutation.mutate(data);
    }
  };

  const handleEdit = (template: any) => {
    setEditingTemplate(template);
    setTemplateForm({
      name: template.name,
      description: template.description || "",
      siteId: template.siteId || "none",
      zoneId: template.zoneId || "none",
      equipmentId: template.equipmentId || "none",
      version: template.version,
      items: template.items || []
    });
    setIsCreateDialogOpen(true);
  };

  const handleDelete = (id: string) => {
    if (confirm("Tem certeza que deseja excluir este template?")) {
      deleteTemplateMutation.mutate(id);
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'photo': return <Eye className="w-4 h-4" />;
      case 'number': return <Hash className="w-4 h-4" />;
      case 'checkbox': return <List className="w-4 h-4" />;
      default: return <FileText className="w-4 h-4" />;
    }
  };

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'photo': return 'Foto';
      case 'number': return 'Número';
      case 'checkbox': return 'Checkbox';
      default: return 'Texto';
    }
  };

  const getSiteName = (siteId: string | null) => {
    if (!siteId) return null;
    return (sites as any[])?.find(s => s.id === siteId)?.name || null;
  };

  const getZoneName = (zoneId: string | null) => {
    if (!zoneId) return null;
    return (zones as any[])?.find(z => z.id === zoneId)?.name || null;
  };

  const getEquipmentName = (equipmentId: string | null) => {
    if (!equipmentId) return null;
    return (equipment as any[])?.find(e => e.id === equipmentId)?.name || null;
  };

  if (isLoading) {
    return (
      <div className="h-full bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 p-6">
        <div className="text-center space-y-4">
          <div className="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-600">Carregando templates...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full overflow-auto bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
      {/* Header */}
      <div className="bg-white/80 backdrop-blur-xl border-b border-white/20 shadow-lg shadow-blue-500/5 sticky top-0 z-50">
        <div className="px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="w-12 h-12 bg-gradient-to-br from-purple-600 via-purple-700 to-indigo-800 rounded-2xl flex items-center justify-center shadow-lg">
                <List className="w-7 h-7 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold bg-gradient-to-r from-slate-900 via-purple-900 to-indigo-900 bg-clip-text text-transparent">
                  Templates de Checklist
                </h1>
                <p className="text-sm text-slate-600">
                  Gerencie os templates de checklist de manutenção
                </p>
              </div>
            </div>
            <Dialog open={isCreateDialogOpen} onOpenChange={(open) => {
              setIsCreateDialogOpen(open);
              if (!open) {
                setEditingTemplate(null);
                resetForm();
              }
            }}>
              <Button 
                className="bg-gradient-to-r from-purple-600 to-indigo-700 hover:from-purple-700 hover:to-indigo-800"
                onClick={() => setIsCreateDialogOpen(true)}
                data-testid="button-create-template"
              >
                <Plus className="w-4 h-4 mr-2" />
                Novo Template
              </Button>
              <DialogContent className="max-w-5xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>
                    {editingTemplate ? "Editar Template" : "Criar Novo Template"}
                  </DialogTitle>
                </DialogHeader>
                
                <div className="space-y-6">
                  {/* Form básico */}
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="name">Nome do Template *</Label>
                      <Input
                        id="name"
                        data-testid="input-template-name"
                        value={templateForm.name}
                        onChange={(e) => setTemplateForm(prev => ({ ...prev, name: e.target.value }))}
                        placeholder="Ex: Manutenção Preventiva HVAC"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="version">Versão</Label>
                      <Input
                        id="version"
                        data-testid="input-template-version"
                        value={templateForm.version}
                        onChange={(e) => setTemplateForm(prev => ({ ...prev, version: e.target.value }))}
                        placeholder="1.0"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Descrição</Label>
                    <Textarea
                      id="description"
                      data-testid="input-template-description"
                      value={templateForm.description}
                      onChange={(e) => setTemplateForm(prev => ({ ...prev, description: e.target.value }))}
                      placeholder="Descrição do template..."
                      rows={2}
                    />
                  </div>

                  {/* Local, Zona e Equipamento */}
                  <div className="grid grid-cols-3 gap-4">
                    <div className="space-y-2">
                      <Label>Local</Label>
                      <Select 
                        value={templateForm.siteId} 
                        onValueChange={(value) => setTemplateForm(prev => ({ 
                          ...prev, 
                          siteId: value,
                          zoneId: "none",
                          equipmentId: "none"
                        }))}
                      >
                        <SelectTrigger data-testid="select-template-site">
                          <SelectValue placeholder="Selecione o local" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Nenhum</SelectItem>
                          {(sites as any[])?.map((site) => (
                            <SelectItem key={site.id} value={site.id}>
                              {site.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Zona</Label>
                      <Select 
                        value={templateForm.zoneId} 
                        onValueChange={(value) => setTemplateForm(prev => ({ 
                          ...prev, 
                          zoneId: value,
                          equipmentId: "none"
                        }))}
                        disabled={templateForm.siteId === "none"}
                      >
                        <SelectTrigger data-testid="select-template-zone">
                          <SelectValue placeholder="Selecione a zona" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Nenhuma</SelectItem>
                          {(zones as any[])?.map((zone) => (
                            <SelectItem key={zone.id} value={zone.id}>
                              {zone.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Equipamento Específico</Label>
                      <Select 
                        value={templateForm.equipmentId} 
                        onValueChange={(value) => setTemplateForm(prev => ({ ...prev, equipmentId: value }))}
                      >
                        <SelectTrigger data-testid="select-template-equipment">
                          <SelectValue placeholder="Selecione o equipamento" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Nenhum</SelectItem>
                          {(equipment as any[])?.map((equip) => (
                            <SelectItem key={equip.id} value={equip.id}>
                              {equip.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  {/* Adicionar item */}
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-lg">Adicionar Item ao Checklist</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="grid grid-cols-3 gap-4">
                        <div className="space-y-2">
                          <Label>Tipo</Label>
                          <Select 
                            value={newItem.type} 
                            onValueChange={(value) => setNewItem(prev => ({ 
                              ...prev, 
                              type: value as ChecklistItem['type'],
                              validation: {}
                            }))}
                          >
                            <SelectTrigger data-testid="select-item-type">
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="text">Texto</SelectItem>
                              <SelectItem value="number">Número</SelectItem>
                              <SelectItem value="photo">Foto</SelectItem>
                              <SelectItem value="checkbox">Checkbox</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                        <div className="space-y-2">
                          <Label>Rótulo *</Label>
                          <Input
                            data-testid="input-item-label"
                            value={newItem.label}
                            onChange={(e) => setNewItem(prev => ({ ...prev, label: e.target.value }))}
                            placeholder="Ex: Verificar pressão"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label>Observações</Label>
                          <Input
                            data-testid="input-item-description"
                            value={newItem.description}
                            onChange={(e) => setNewItem(prev => ({ ...prev, description: e.target.value }))}
                            placeholder="Instruções opcionais..."
                          />
                        </div>
                      </div>

                      {/* Configurações avançadas */}
                      {newItem.type && (
                        <Card className="bg-slate-50">
                          <CardHeader className="pb-3">
                            <CardTitle className="text-sm">Configurações - {getTypeLabel(newItem.type)}</CardTitle>
                          </CardHeader>
                          <CardContent className="space-y-3">
                            {/* Texto */}
                            {newItem.type === 'text' && (
                              <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                  <Label className="text-xs">Mínimo de caracteres</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 10"
                                    value={newItem.validation?.minLength || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        minLength: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                                <div className="space-y-1">
                                  <Label className="text-xs">Máximo de caracteres</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 500"
                                    value={newItem.validation?.maxLength || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        maxLength: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                              </div>
                            )}

                            {/* Número */}
                            {newItem.type === 'number' && (
                              <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                  <Label className="text-xs">Valor mínimo</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 0"
                                    value={newItem.validation?.minValue || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        minValue: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                                <div className="space-y-1">
                                  <Label className="text-xs">Valor máximo</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 100"
                                    value={newItem.validation?.maxValue || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        maxValue: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                              </div>
                            )}

                            {/* Foto */}
                            {newItem.type === 'photo' && (
                              <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                  <Label className="text-xs">Mínimo de fotos</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 1"
                                    value={newItem.validation?.photoMinCount || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        photoMinCount: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                                <div className="space-y-1">
                                  <Label className="text-xs">Máximo de fotos</Label>
                                  <Input
                                    type="number"
                                    placeholder="Ex: 5"
                                    value={newItem.validation?.photoMaxCount || ""}
                                    onChange={(e) => setNewItem(prev => ({
                                      ...prev,
                                      validation: {
                                        ...prev.validation,
                                        photoMaxCount: e.target.value ? parseInt(e.target.value) : undefined
                                      }
                                    }))}
                                    className="h-8 text-xs"
                                  />
                                </div>
                              </div>
                            )}

                            {/* Campo obrigatório */}
                            <div className="flex items-center space-x-2 pt-2">
                              <Switch
                                id="required"
                                checked={newItem.required}
                                onCheckedChange={(checked) => setNewItem(prev => ({ ...prev, required: checked }))}
                              />
                              <Label htmlFor="required" className="text-sm cursor-pointer">
                                Campo obrigatório
                              </Label>
                            </div>
                          </CardContent>
                        </Card>
                      )}

                      <Button 
                        onClick={handleAddItem} 
                        className="w-full"
                        data-testid="button-add-item"
                      >
                        <Plus className="w-4 h-4 mr-2" />
                        Adicionar Item
                      </Button>
                    </CardContent>
                  </Card>

                  {/* Lista de itens adicionados */}
                  {templateForm.items.length > 0 && (
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-lg">Itens do Checklist ({templateForm.items.length})</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-2">
                          {templateForm.items.map((item, index) => (
                            <div 
                              key={item.id} 
                              className="flex items-center justify-between p-3 bg-slate-50 rounded-lg hover:bg-slate-100"
                              data-testid={`item-${item.id}`}
                            >
                              <div className="flex items-center space-x-3 flex-1">
                                <span className="text-sm font-medium text-slate-500 w-8">
                                  {index + 1}.
                                </span>
                                <div className="flex items-center space-x-2">
                                  {getTypeIcon(item.type)}
                                  <Badge variant="outline" className="text-xs">
                                    {getTypeLabel(item.type)}
                                  </Badge>
                                </div>
                                <div className="flex-1">
                                  <div className="font-medium text-sm">{item.label}</div>
                                  {item.description && (
                                    <div className="text-xs text-slate-500">{item.description}</div>
                                  )}
                                </div>
                                {item.required && (
                                  <Badge variant="destructive" className="text-xs">Obrigatório</Badge>
                                )}
                              </div>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleRemoveItem(item.id)}
                                data-testid={`button-remove-item-${item.id}`}
                              >
                                <Trash2 className="w-4 h-4 text-red-500" />
                              </Button>
                            </div>
                          ))}
                        </div>
                      </CardContent>
                    </Card>
                  )}

                  {/* Actions */}
                  <div className="flex justify-end space-x-2 pt-4">
                    <Button 
                      variant="outline" 
                      onClick={() => {
                        setIsCreateDialogOpen(false);
                        setEditingTemplate(null);
                        resetForm();
                      }}
                      data-testid="button-cancel"
                    >
                      Cancelar
                    </Button>
                    <Button 
                      onClick={handleSubmit}
                      disabled={createTemplateMutation.isPending || updateTemplateMutation.isPending}
                      data-testid="button-save-template"
                    >
                      {editingTemplate ? "Atualizar" : "Criar"} Template
                    </Button>
                  </div>
                </div>
              </DialogContent>
            </Dialog>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-8">
        <Card>
          <CardHeader>
            <CardTitle>Templates de Checklist de Manutenção</CardTitle>
          </CardHeader>
          <CardContent>
            {!templates || (templates as any[]).length === 0 ? (
              <div className="text-center py-12">
                <List className="w-16 h-16 mx-auto text-slate-300 mb-4" />
                <p className="text-slate-500">Nenhum template cadastrado</p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nome</TableHead>
                    <TableHead>Local</TableHead>
                    <TableHead>Zona</TableHead>
                    <TableHead>Equipamento</TableHead>
                    <TableHead>Versão</TableHead>
                    <TableHead>Itens</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(templates as any[]).map((template) => (
                    <TableRow key={template.id} data-testid={`row-template-${template.id}`}>
                      <TableCell className="font-medium">{template.name}</TableCell>
                      <TableCell>
                        {template.siteId ? (
                          <Badge variant="outline">{getSiteName(template.siteId)}</Badge>
                        ) : (
                          <span className="text-slate-400">-</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {template.zoneId ? (
                          <Badge variant="outline">{getZoneName(template.zoneId)}</Badge>
                        ) : (
                          <span className="text-slate-400">-</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {template.equipmentId ? (
                          <Badge variant="outline">{getEquipmentName(template.equipmentId)}</Badge>
                        ) : (
                          <span className="text-slate-400">-</span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">{template.version}</Badge>
                      </TableCell>
                      <TableCell>
                        <Badge>{(template.items || []).length}</Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end space-x-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEdit(template)}
                            data-testid={`button-edit-${template.id}`}
                          >
                            <Edit3 className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(template.id)}
                            data-testid={`button-delete-${template.id}`}
                          >
                            <Trash2 className="w-4 h-4 text-red-500" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
