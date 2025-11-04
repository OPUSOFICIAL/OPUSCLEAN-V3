import Header from "@/components/layout/header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";
import { useModule } from "@/contexts/ModuleContext";
import { 
  Plus, 
  Settings, 
  Edit, 
  Trash2,
  Wrench,
  MapPin,
  ChevronDown
} from "lucide-react";

interface EquipmentProps {
  customerId: string;
}

function MultiSelect({
  label,
  options,
  value,
  onChange,
  placeholder,
  disabled,
  "data-testid": dataTestId,
}: {
  label: string;
  options: { value: string; label: string }[];
  value: string[];
  onChange: (vals: string[]) => void;
  placeholder?: string;
  disabled?: boolean;
  "data-testid"?: string;
}) {
  const [open, setOpen] = useState(false);
  
  const toggleOption = (optionValue: string) => {
    if (value.includes(optionValue)) {
      onChange(value.filter(v => v !== optionValue));
    } else {
      onChange([...value, optionValue]);
    }
  };

  const selectedLabels = options
    .filter(opt => value.includes(opt.value))
    .map(opt => opt.label)
    .join(", ");

  return (
    <div className="space-y-2">
      <Label>{label}</Label>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-full justify-between"
            disabled={disabled}
            data-testid={dataTestId}
          >
            <span className="truncate">
              {selectedLabels || placeholder || "Selecione..."}
            </span>
            <ChevronDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-full p-0" align="start">
          <div className="max-h-64 overflow-auto p-2">
            {options.length === 0 ? (
              <div className="p-2 text-sm text-muted-foreground">
                {placeholder || "Sem opções"}
              </div>
            ) : (
              <div className="space-y-1">
                {options.map((option) => (
                  <div
                    key={option.value}
                    className="flex items-center space-x-2 p-2 hover:bg-accent rounded-sm cursor-pointer"
                    onClick={() => toggleOption(option.value)}
                  >
                    <Checkbox
                      checked={value.includes(option.value)}
                      onCheckedChange={() => toggleOption(option.value)}
                    />
                    <label className="flex-1 cursor-pointer text-sm">
                      {option.label}
                    </label>
                  </div>
                ))}
              </div>
            )}
          </div>
        </PopoverContent>
      </Popover>
      <div className="text-xs text-slate-500">
        {value?.length ? `${value.length} selecionado(s)` : "Nenhum selecionado"}
      </div>
    </div>
  );
}

export default function Equipment({ customerId }: EquipmentProps) {
  const { currentModule } = useModule();
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingEquipment, setEditingEquipment] = useState<any>(null);

  // Equipamentos é exclusivo do módulo de manutenção
  if (currentModule !== 'maintenance') {
    return (
      <div className="h-full bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50 flex items-center justify-center p-6">
        <Card className="max-w-md">
          <CardHeader>
            <CardTitle className="text-center">Funcionalidade Não Disponível</CardTitle>
          </CardHeader>
          <CardContent className="text-center space-y-4">
            <Wrench className="w-16 h-16 mx-auto text-slate-400" />
            <p className="text-slate-600">
              A gestão de equipamentos está disponível apenas no módulo <strong>OPUS Manutenção</strong>.
            </p>
            <p className="text-sm text-slate-500">
              Alterne para OPUS Manutenção usando o seletor de plataforma na barra lateral.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }
  
  // Form states
  const [selectedSiteId, setSelectedSiteId] = useState("");
  const [selectedZoneId, setSelectedZoneId] = useState("");
  const [equipmentName, setEquipmentName] = useState("");
  const [equipmentType, setEquipmentType] = useState("");
  const [manufacturer, setManufacturer] = useState("");
  const [model, setModel] = useState("");
  const [serialNumber, setSerialNumber] = useState("");
  const [installationDate, setInstallationDate] = useState("");
  const [warrantyExpiry, setWarrantyExpiry] = useState("");
  const [status, setStatus] = useState("operacional");
  const [description, setDescription] = useState("");

  const { toast } = useToast();

  // Fetch customer data
  const { data: customer } = useQuery({
    queryKey: [`/api/customers/${customerId}`],
    enabled: !!customerId,
  });

  // Fetch sites
  const { data: sites } = useQuery({
    queryKey: [`/api/customers/${customerId}/sites`, { module: currentModule }],
    enabled: !!customerId,
  });

  // Fetch zones for selected site
  const { data: zones } = useQuery({
    queryKey: [`/api/sites/${selectedSiteId}/zones`, { module: currentModule }],
    enabled: !!selectedSiteId,
  });

  // Fetch equipment
  const { data: equipment, isLoading } = useQuery({
    queryKey: [`/api/customers/${customerId}/equipment`],
    enabled: !!customerId,
  });

  // Fetch equipment tags
    queryKey: [`/api/customers/${customerId}/equipment-tags`, { module: currentModule }],
    enabled: !!customerId,
  });

  const createEquipmentMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("POST", "/api/equipment", data);
    },
    onSuccess: () => {
      toast({ title: "Equipamento criado com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/equipment`] });
      setIsCreateDialogOpen(false);
      resetForm();
    },
    onError: () => {
      toast({ 
        title: "Erro ao criar equipamento", 
        variant: "destructive" 
      });
    },
  });

  const updateEquipmentMutation = useMutation({
    mutationFn: async (data: any) => {
      return await apiRequest("PUT", `/api/equipment/${data.id}`, data);
    },
    onSuccess: () => {
      toast({ title: "Equipamento atualizado com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/equipment`] });
      setIsEditDialogOpen(false);
      setEditingEquipment(null);
      resetForm();
    },
    onError: () => {
      toast({ 
        title: "Erro ao atualizar equipamento", 
        variant: "destructive" 
      });
    },
  });

  const deleteEquipmentMutation = useMutation({
    mutationFn: async (id: string) => {
      return await apiRequest("DELETE", `/api/equipment/${id}`);
    },
    onSuccess: () => {
      toast({ title: "Equipamento excluído com sucesso" });
      queryClient.invalidateQueries({ queryKey: [`/api/customers/${customerId}/equipment`] });
    },
    onError: () => {
      toast({ 
        title: "Erro ao excluir equipamento", 
        variant: "destructive" 
      });
    },
  });

  const resetForm = () => {
    setSelectedSiteId("");
    setSelectedZoneId("");
    setTagIds([]);
    setEquipmentName("");
    setEquipmentType("");
    setManufacturer("");
    setModel("");
    setSerialNumber("");
    setInstallationDate("");
    setWarrantyExpiry("");
    setStatus("operacional");
    setDescription("");
  };

  const handleCreate = () => {
    const companyId = (customer as any)?.companyId;
    if (!companyId || !selectedSiteId) {
      toast({ 
        title: "Preencha todos os campos obrigatórios", 
        variant: "destructive" 
      });
      return;
    }

    createEquipmentMutation.mutate({
      companyId,
      customerId,
      siteId: selectedSiteId,
      zoneId: selectedZoneId || null,
      name: equipmentName,
      equipmentType,
      manufacturer: manufacturer || null,
      model: model || null,
      serialNumber: serialNumber || null,
      installationDate: installationDate || null,
      warrantyExpiry: warrantyExpiry || null,
      status,
      description: description || null,
      module: currentModule,
    });
  };

  const handleEdit = (equip: any) => {
    setEditingEquipment(equip);
    setSelectedSiteId(equip.siteId);
    setSelectedZoneId(equip.zoneId || "");
    setEquipmentName(equip.name);
    setEquipmentType(equip.equipmentType);
    setManufacturer(equip.manufacturer || "");
    setModel(equip.model || "");
    setSerialNumber(equip.serialNumber || "");
    setInstallationDate(equip.installationDate || "");
    setWarrantyExpiry(equip.warrantyExpiry || "");
    setStatus(equip.status);
    setDescription(equip.description || "");
    setIsEditDialogOpen(true);
  };

  const handleUpdate = () => {
    const companyId = (customer as any)?.companyId;
    if (!editingEquipment || !companyId) return;

    updateEquipmentMutation.mutate({
      id: editingEquipment.id,
      companyId,
      customerId,
      siteId: selectedSiteId,
      zoneId: selectedZoneId || null,
      name: equipmentName,
      equipmentType,
      manufacturer: manufacturer || null,
      model: model || null,
      serialNumber: serialNumber || null,
      installationDate: installationDate || null,
      warrantyExpiry: warrantyExpiry || null,
      status,
      description: description || null,
    });
  };

  const handleDelete = (id: string) => {
    if (confirm("Tem certeza que deseja excluir este equipamento?")) {
      deleteEquipmentMutation.mutate(id);
    }
  };

  // Get site and zone names for display
  const getSiteName = (siteId: string) => {
    if (!Array.isArray(sites)) return "N/A";
    return sites.find((s: any) => s.id === siteId)?.name || "N/A";
  };

  const getZoneName = (zoneId: string | null) => {
    if (!zoneId) return "N/A";
    // We need to fetch all zones for this
    return zoneId;
  };

  return (
    <div className="min-h-screen bg-background">
      <Header title="Equipamentos" description="Gerencie equipamentos e ativos" />

      <div className="container mx-auto px-4 py-6 space-y-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
            <div className="flex items-center gap-2">
              <Wrench className="h-5 w-5 text-primary" />
              <CardTitle>Lista de Equipamentos</CardTitle>
            </div>
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button data-testid="button-create-equipment">
                  <Plus className="mr-2 h-4 w-4" />
                  Novo Equipamento
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle>Criar Novo Equipamento</DialogTitle>
                  <DialogDescription>
                    Cadastre um novo equipamento no sistema
                  </DialogDescription>
                </DialogHeader>
                
                <div className="grid gap-4 py-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="site">Local *</Label>
                      <Select value={selectedSiteId} onValueChange={setSelectedSiteId}>
                        <SelectTrigger data-testid="select-site">
                          <SelectValue placeholder="Selecione um local" />
                        </SelectTrigger>
                        <SelectContent>
                          {Array.isArray(sites) && sites.map((site: any) => (
                            <SelectItem key={site.id} value={site.id}>
                              {site.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="zone">Zona (Opcional)</Label>
                      <Select value={selectedZoneId} onValueChange={setSelectedZoneId} disabled={!selectedSiteId}>
                        <SelectTrigger data-testid="select-zone">
                          <SelectValue placeholder="Selecione uma zona" />
                        </SelectTrigger>
                        <SelectContent>
                          {Array.isArray(zones) && zones.map((zone: any) => (
                            <SelectItem key={zone.id} value={zone.id}>
                              {zone.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <MultiSelect
                      label="Tags"
                      onChange={setTagIds}
                      placeholder="Selecione as tags"
                      data-testid="select-equipment-tags"
                    />

                    <div className="space-y-2">
                      <Label htmlFor="name">Nome do Equipamento *</Label>
                      <Input
                        id="name"
                        data-testid="input-equipment-name"
                        value={equipmentName}
                        onChange={(e) => setEquipmentName(e.target.value)}
                        placeholder="Ex: Ar Condicionado"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="type">Tipo de Equipamento *</Label>
                      <Select value={equipmentType} onValueChange={setEquipmentType}>
                        <SelectTrigger data-testid="select-equipment-type">
                          <SelectValue placeholder="Selecione o tipo" />
                        </SelectTrigger>
                        <SelectContent>
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
                      <Label htmlFor="status">Status</Label>
                      <Select value={status} onValueChange={setStatus}>
                        <SelectTrigger data-testid="select-status">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="operacional">Operacional</SelectItem>
                          <SelectItem value="em_manutencao">Em Manutenção</SelectItem>
                          <SelectItem value="inoperante">Inoperante</SelectItem>
                          <SelectItem value="aposentado">Aposentado</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="manufacturer">Fabricante</Label>
                      <Input
                        id="manufacturer"
                        data-testid="input-manufacturer"
                        value={manufacturer}
                        onChange={(e) => setManufacturer(e.target.value)}
                        placeholder="Ex: Samsung"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="model">Modelo</Label>
                      <Input
                        id="model"
                        data-testid="input-model"
                        value={model}
                        onChange={(e) => setModel(e.target.value)}
                        placeholder="Ex: AR9000"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="serialNumber">Número de Série</Label>
                      <Input
                        id="serialNumber"
                        data-testid="input-serial-number"
                        value={serialNumber}
                        onChange={(e) => setSerialNumber(e.target.value)}
                        placeholder="SN123456"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="installationDate">Data de Instalação</Label>
                      <Input
                        id="installationDate"
                        type="date"
                        data-testid="input-installation-date"
                        value={installationDate}
                        onChange={(e) => setInstallationDate(e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="warrantyExpiry">Vencimento da Garantia</Label>
                    <Input
                      id="warrantyExpiry"
                      type="date"
                      data-testid="input-warranty-expiry"
                      value={warrantyExpiry}
                      onChange={(e) => setWarrantyExpiry(e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Descrição</Label>
                    <Textarea
                      id="description"
                      data-testid="input-description"
                      value={description}
                      onChange={(e) => setDescription(e.target.value)}
                      placeholder="Informações adicionais sobre o equipamento"
                      rows={3}
                    />
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
                    disabled={createEquipmentMutation.isPending}
                    data-testid="button-save"
                  >
                    {createEquipmentMutation.isPending ? "Criando..." : "Criar Equipamento"}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          </CardHeader>

          <CardContent>
            {isLoading ? (
              <div className="text-center py-8">Carregando equipamentos...</div>
            ) : !Array.isArray(equipment) || equipment.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                Nenhum equipamento cadastrado
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Código</TableHead>
                    <TableHead>TAG</TableHead>
                    <TableHead>Nome</TableHead>
                    <TableHead>Tipo</TableHead>
                    <TableHead>Local</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Fabricante</TableHead>
                    <TableHead>Modelo</TableHead>
                    <TableHead className="text-right">Ações</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {Array.isArray(equipment) && equipment.map((equip: any) => (
                    <TableRow key={equip.id} data-testid={`row-equipment-${equip.id}`}>
                      <TableCell className="font-mono text-sm">
                        {equip.internalCode || "-"}
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-wrap gap-1">
                              return tagObj ? (
                                <Badge key={tagId} variant="secondary" className="text-xs">
                                  {tagObj.name}
                                </Badge>
                              ) : null;
                            })
                          ) : (
                            <span className="text-muted-foreground text-sm">-</span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="font-medium">{equip.name}</TableCell>
                      <TableCell className="capitalize">{equip.equipmentType}</TableCell>
                      <TableCell>{getSiteName(equip.siteId)}</TableCell>
                      <TableCell>
                        <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${
                          equip.status === 'operacional' ? 'bg-green-100 text-green-800' :
                          equip.status === 'em_manutencao' ? 'bg-yellow-100 text-yellow-800' :
                          equip.status === 'inoperante' ? 'bg-red-100 text-red-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {equip.status === 'operacional' ? 'Operacional' :
                           equip.status === 'em_manutencao' ? 'Em Manutenção' :
                           equip.status === 'inoperante' ? 'Inoperante' :
                           'Aposentado'}
                        </span>
                      </TableCell>
                      <TableCell>{equip.manufacturer || "-"}</TableCell>
                      <TableCell>{equip.model || "-"}</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEdit(equip)}
                            data-testid={`button-edit-${equip.id}`}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(equip.id)}
                            data-testid={`button-delete-${equip.id}`}
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

        {/* Edit Dialog - Similar structure to create dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Editar Equipamento</DialogTitle>
              <DialogDescription>
                Atualize as informações do equipamento
              </DialogDescription>
            </DialogHeader>
            
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="edit-site">Local *</Label>
                  <Select value={selectedSiteId} onValueChange={setSelectedSiteId}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione um local" />
                    </SelectTrigger>
                    <SelectContent>
                      {Array.isArray(sites) && sites.map((site: any) => (
                        <SelectItem key={site.id} value={site.id}>
                          {site.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="edit-zone">Zona (Opcional)</Label>
                  <Select value={selectedZoneId} onValueChange={setSelectedZoneId} disabled={!selectedSiteId}>
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione uma zona" />
                    </SelectTrigger>
                    <SelectContent>
                      {Array.isArray(zones) && zones.map((zone: any) => (
                        <SelectItem key={zone.id} value={zone.id}>
                          {zone.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <MultiSelect
                  label="Tags"
                  onChange={setTagIds}
                  placeholder="Selecione as tags"
                  data-testid="select-edit-equipment-tags"
                />

                <div className="space-y-2">
                  <Label>Nome do Equipamento *</Label>
                  <Input
                    value={equipmentName}
                    onChange={(e) => setEquipmentName(e.target.value)}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Tipo de Equipamento *</Label>
                  <Select value={equipmentType} onValueChange={setEquipmentType}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
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
                  <Label>Status</Label>
                  <Select value={status} onValueChange={setStatus}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="operacional">Operacional</SelectItem>
                      <SelectItem value="em_manutencao">Em Manutenção</SelectItem>
                      <SelectItem value="inoperante">Inoperante</SelectItem>
                      <SelectItem value="aposentado">Aposentado</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Fabricante</Label>
                  <Input
                    value={manufacturer}
                    onChange={(e) => setManufacturer(e.target.value)}
                  />
                </div>

                <div className="space-y-2">
                  <Label>Modelo</Label>
                  <Input
                    value={model}
                    onChange={(e) => setModel(e.target.value)}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Número de Série</Label>
                  <Input
                    value={serialNumber}
                    onChange={(e) => setSerialNumber(e.target.value)}
                  />
                </div>

                <div className="space-y-2">
                  <Label>Data de Instalação</Label>
                  <Input
                    type="date"
                    value={installationDate}
                    onChange={(e) => setInstallationDate(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Vencimento da Garantia</Label>
                <Input
                  type="date"
                  value={warrantyExpiry}
                  onChange={(e) => setWarrantyExpiry(e.target.value)}
                />
              </div>

              <div className="space-y-2">
                <Label>Descrição</Label>
                <Textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                />
              </div>
            </div>

            <div className="flex justify-end gap-2">
              <Button
                variant="outline"
                onClick={() => {
                  setIsEditDialogOpen(false);
                  setEditingEquipment(null);
                  resetForm();
                }}
              >
                Cancelar
              </Button>
              <Button
                onClick={handleUpdate}
                disabled={updateEquipmentMutation.isPending}
              >
                {updateEquipmentMutation.isPending ? "Atualizando..." : "Atualizar"}
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
