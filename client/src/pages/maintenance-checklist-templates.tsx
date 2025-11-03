import Header from "@/components/layout/header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";
import { useModule } from "@/contexts/ModuleContext";
import { 
  Plus, 
  CheckCircle2,
  Edit, 
  Trash2,
  List
} from "lucide-react";

interface MaintenanceChecklistTemplatesProps {
  customerId: string;
}

export default function MaintenanceChecklistTemplates({ customerId }: MaintenanceChecklistTemplatesProps) {
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingTemplate, setEditingTemplate] = useState<any>(null);
  
  // Form states
  const [templateName, setTemplateName] = useState("");
  const [equipmentType, setEquipmentType] = useState("");
  const [selectedEquipmentId, setSelectedEquipmentId] = useState("");
  const [version, setVersion] = useState("1.0");
  const [description, setDescription] = useState("");
  const [checklistItems, setChecklistItems] = useState("[]");

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

  // Fetch equipment for dropdown
  const { data: equipment } = useQuery({
    queryKey: [`/api/customers/${customerId}/equipment`, { module: currentModule }],
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
      setIsEditDialogOpen(false);
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
    setTemplateName("");
    setEquipmentType("");
    setSelectedEquipmentId("");
    setVersion("1.0");
    setDescription("");
    setChecklistItems("[]");
  };

  const handleCreate = () => {
    const companyId = (customer as any)?.companyId;
    if (!companyId || !templateName) {
      toast({ 
        title: "Preencha todos os campos obrigatórios", 
        variant: "destructive" 
      });
      return;
    }

    // Validate JSON
    let items;
    try {
      items = JSON.parse(checklistItems);
      if (!Array.isArray(items)) {
        throw new Error("Items deve ser um array");
      }
    } catch (error) {
      toast({ 
        title: "JSON inválido nos itens do checklist", 
        variant: "destructive" 
      });
      return;
    }

    createTemplateMutation.mutate({
      companyId,
      customerId,
      name: templateName,
      equipmentType: equipmentType || null,
      equipmentId: selectedEquipmentId || null,
      version,
      items,
      description: description || null,
    });
  };

  const handleEdit = (template: any) => {
    setEditingTemplate(template);
    setTemplateName(template.name);
    setEquipmentType(template.equipmentType || "");
    setSelectedEquipmentId(template.equipmentId || "");
    setVersion(template.version);
    setDescription(template.description || "");
    setChecklistItems(JSON.stringify(template.items, null, 2));
    setIsEditDialogOpen(true);
  };

  const handleUpdate = () => {
    const companyId = (customer as any)?.companyId;
    if (!editingTemplate || !companyId) return;

    // Validate JSON
    let items;
    try {
      items = JSON.parse(checklistItems);
      if (!Array.isArray(items)) {
        throw new Error("Items deve ser um array");
      }
    } catch (error) {
      toast({ 
        title: "JSON inválido nos itens do checklist", 
        variant: "destructive" 
      });
      return;
    }

    updateTemplateMutation.mutate({
      id: editingTemplate.id,
      companyId,
      customerId,
      name: templateName,
      equipmentType: equipmentType || null,
      equipmentId: selectedEquipmentId || null,
      version,
      items,
      description: description || null,
    });
  };

  const handleDelete = (id: string) => {
    if (confirm("Tem certeza que deseja excluir este template?")) {
      deleteTemplateMutation.mutate(id);
    }
  };

  const getEquipmentName = (equipmentId: string | null) => {
    if (!equipmentId || !Array.isArray(equipment)) return null;
    return equipment.find((e: any) => e.id === equipmentId)?.name || null;
  };

  const addSampleItem = () => {
    const sample = [
      {
        id: "1",
        description: "Verificar estado geral",
        required: true
      },
      {
        id: "2",
        description: "Limpar componentes",
        required: true
      },
      {
        id: "3",
        description: "Testar funcionamento",
        required: true
      }
    ];
    setChecklistItems(JSON.stringify(sample, null, 2));
  };

  return (
    <div className="min-h-screen bg-background">
      <Header title="Templates de Checklist" description="Modelos de checklist para manutenção" />

      <div className="container mx-auto px-4 py-6 space-y-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
            <div className="flex items-center gap-2">
              <List className="h-5 w-5 text-primary" />
              <CardTitle>Lista de Templates</CardTitle>
            </div>
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button data-testid="button-create-template">
                  <Plus className="mr-2 h-4 w-4" />
                  Novo Template
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>Criar Novo Template de Checklist</DialogTitle>
                  <DialogDescription>
                    Defina um modelo de checklist reutilizável
                  </DialogDescription>
                </DialogHeader>
                
                <div className="grid gap-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="templateName">Nome do Template *</Label>
                    <Input
                      id="templateName"
                      data-testid="input-template-name"
                      value={templateName}
                      onChange={(e) => setTemplateName(e.target.value)}
                      placeholder="Ex: Checklist HVAC Mensal"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="equipmentType">Tipo de Equipamento (Genérico)</Label>
                      <Select value={equipmentType} onValueChange={setEquipmentType}>
                        <SelectTrigger data-testid="select-equipment-type">
                          <SelectValue placeholder="Selecione o tipo" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="">Nenhum</SelectItem>
                          <SelectItem value="hvac">HVAC</SelectItem>
                          <SelectItem value="eletrico">Elétrico</SelectItem>
                          <SelectItem value="hidraulico">Hidráulico</SelectItem>
                          <SelectItem value="mecanico">Mecânico</SelectItem>
                          <SelectItem value="eletronico">Eletrônico</SelectItem>
                          <SelectItem value="outro">Outro</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="equipmentId">Equipamento Específico</Label>
                      <Select value={selectedEquipmentId} onValueChange={setSelectedEquipmentId}>
                        <SelectTrigger data-testid="select-equipment">
                          <SelectValue placeholder="Selecione se aplicável" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="">Nenhum</SelectItem>
                          {Array.isArray(equipment) && equipment.map((equip: any) => (
                            <SelectItem key={equip.id} value={equip.id}>
                              {equip.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="version">Versão</Label>
                    <Input
                      id="version"
                      data-testid="input-version"
                      value={version}
                      onChange={(e) => setVersion(e.target.value)}
                      placeholder="1.0"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Descrição</Label>
                    <Textarea
                      id="description"
                      data-testid="input-description"
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Descreva quando e como usar este template"
                      rows={2}
                    />
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <Label htmlFor="items">Itens do Checklist (JSON) *</Label>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={addSampleItem}
                        data-testid="button-add-sample"
                      >
                        Adicionar Exemplo
                      </Button>
                    </div>
                    <Textarea
                      id="items"
                      data-testid="input-items"
                      value={checklistItems}
                      onChange={(e) => setChecklistItems(e.target.value)}
                      placeholder='[{"id": "1", "description": "Item 1", "required": true}]'
                      rows={8}
                      className="font-mono text-sm"
                    />
                    <p className="text-xs text-muted-foreground">
                      Formato: Array de objetos com id, description e required
                    </p>
                  </div>
                </div>

                <div className="flex justify-end gap-2">
                  <Button
                    variant="outline"
                    onClick={() => setIsCreateDialogOpen(false)}
                    data-testid="button-cancel"
                  >
                    Cancelar
                  </Button>
                  <Button
                    onClick={handleCreate}
                    disabled={createTemplateMutation.isPending}
                    data-testid="button-save"
                  >
                    {createTemplateMutation.isPending ? "Criando..." : "Criar Template"}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          </CardHeader>

          <CardContent>
            {isLoading ? (
              <div className="text-center py-8">Carregando templates...</div>
            ) : !Array.isArray(templates) || templates.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                Nenhum template cadastrado
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Nome</TableHead>
                    <TableHead>Tipo de Equipamento</TableHead>
                    <TableHead>Equipamento Específico</TableHead>
                    <TableHead>Versão</TableHead>
                    <TableHead>Itens</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {Array.isArray(templates) && templates.map((template: any) => (
                    <TableRow key={template.id} data-testid={`row-template-${template.id}`}>
                      <TableCell className="font-medium">{template.name}</TableCell>
                      <TableCell>
                        {template.equipmentType ? (
                          <Badge variant="outline" className="capitalize">
                            {template.equipmentType}
                          </Badge>
                        ) : (
                          <span className="text-muted-foreground">-</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {template.equipmentId ? (
                          <span>{getEquipmentName(template.equipmentId) || template.equipmentId}</span>
                        ) : (
                          <span className="text-muted-foreground">Genérico</span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="secondary">{template.version}</Badge>
                      </TableCell>
                      <TableCell>
                        {Array.isArray(template.items) ? template.items.length : 0} itens
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEdit(template)}
                            data-testid={`button-edit-${template.id}`}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(template.id)}
                            data-testid={`button-delete-${template.id}`}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
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

        {/* Edit Dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Editar Template de Checklist</DialogTitle>
            </DialogHeader>
            
            <div className="grid gap-4 py-4">
              <div className="space-y-2">
                <Label>Nome do Template *</Label>
                <Input
                  value={templateName}
                  onChange={(e) => setTemplateName(e.target.value)}
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Tipo de Equipamento (Genérico)</Label>
                  <Select value={equipmentType} onValueChange={setEquipmentType}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="">Nenhum</SelectItem>
                      <SelectItem value="hvac">HVAC</SelectItem>
                      <SelectItem value="eletrico">Elétrico</SelectItem>
                      <SelectItem value="hidraulico">Hidráulico</SelectItem>
                      <SelectItem value="mecanico">Mecânico</SelectItem>
                      <SelectItem value="eletronico">Eletrônico</SelectItem>
                      <SelectItem value="outro">Outro</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>Equipamento Específico</Label>
                  <Select value={selectedEquipmentId} onValueChange={setSelectedEquipmentId}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="">Nenhum</SelectItem>
                      {Array.isArray(equipment) && equipment.map((equip: any) => (
                        <SelectItem key={equip.id} value={equip.id}>
                          {equip.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-2">
                <Label>Versão</Label>
                <Input
                  value={version}
                  onChange={(e) => setVersion(e.target.value)}
                />
              </div>

              <div className="space-y-2">
                <Label>Descrição</Label>
                <Textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={2}
                />
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label>Itens do Checklist (JSON) *</Label>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={addSampleItem}
                  >
                    Adicionar Exemplo
                  </Button>
                </div>
                <Textarea
                  value={checklistItems}
                  onChange={(e) => setChecklistItems(e.target.value)}
                  rows={8}
                  className="font-mono text-sm"
                />
              </div>
            </div>

            <div className="flex justify-end gap-2">
              <Button
                variant="outline"
                onClick={() => {
                  setIsEditDialogOpen(false);
                  setEditingTemplate(null);
                  resetForm();
                }}
              >
                Cancelar
              </Button>
              <Button
                onClick={handleUpdate}
                disabled={updateTemplateMutation.isPending}
              >
                {updateTemplateMutation.isPending ? "Atualizando..." : "Atualizar"}
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
