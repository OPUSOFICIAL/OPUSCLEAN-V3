import { useState, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Plus, Edit, Trash2, Tag } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import Header from "@/components/layout/header";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import type { EquipmentTag } from "@shared/schema";

const equipmentTagSchema = z.object({
  name: z.string().min(1, "Nome é obrigatório"),
  description: z.string().optional(),
});

export default function EquipmentTags() {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingTag, setEditingTag] = useState<any>(null);
  const { toast } = useToast();
  const { activeClientId: customerId } = useClient();
  const { currentModule } = useModule();

  useEffect(() => {
    if (customerId) {
      queryClient.invalidateQueries({ queryKey: ["/api/customers"] });
    }
  }, [customerId]);

  const { data: equipmentTags = [], isLoading } = useQuery<EquipmentTag[]>({
    queryKey: ["/api/customers", customerId, "equipment-tags", { module: currentModule }],
    enabled: !!customerId,
  });

  const tagForm = useForm({
    resolver: zodResolver(equipmentTagSchema),
    defaultValues: {
      name: "",
      description: "",
    },
  });

  const createTagMutation = useMutation({
    mutationFn: (data: any) => apiRequest("POST", `/api/customers/${customerId}/equipment-tags`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "equipment-tags"] });
      setIsDialogOpen(false);
      tagForm.reset();
      toast({ title: "Tag criada com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao criar tag", variant: "destructive" });
    },
  });

  const updateTagMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => 
      apiRequest("PUT", `/api/customers/${customerId}/equipment-tags/${id}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "equipment-tags"] });
      setIsDialogOpen(false);
      setEditingTag(null);
      tagForm.reset();
      toast({ title: "Tag atualizada com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao atualizar tag", variant: "destructive" });
    },
  });

  const deleteTagMutation = useMutation({
    mutationFn: (id: string) => apiRequest("DELETE", `/api/customers/${customerId}/equipment-tags/${id}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/customers", customerId, "equipment-tags"] });
      toast({ title: "Tag excluída com sucesso!" });
    },
    onError: () => {
      toast({ title: "Erro ao excluir tag", variant: "destructive" });
    },
  });

  const handleSubmit = (data: z.infer<typeof equipmentTagSchema>) => {
    const payload = {
      ...data,
      customerId,
      module: currentModule,
      isActive: true,
    };

    if (editingTag) {
      updateTagMutation.mutate({ id: editingTag.id, data: payload });
    } else {
      createTagMutation.mutate(payload);
    }
  };

  const handleEdit = (tag: any) => {
    setEditingTag(tag);
    tagForm.reset({
      name: tag.name,
      description: tag.description || "",
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (id: string) => {
    if (window.confirm("Tem certeza que deseja excluir esta tag?")) {
      deleteTagMutation.mutate(id);
    }
  };

  const handleOpenDialog = () => {
    setEditingTag(null);
    tagForm.reset({
      name: "",
      description: "",
    });
    setIsDialogOpen(true);
  };

  return (
    <div className="flex flex-col h-screen bg-gray-50 dark:bg-gray-900">
      <Header title="Tags de Equipamentos" />
      <main className="flex-1 overflow-y-auto p-6">
        <div className="max-w-6xl mx-auto space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-100">
                Tags de Equipamentos
              </h1>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                Gerencie tags para categorizar e identificar equipamentos
              </p>
            </div>
          </div>

          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Tag className="h-5 w-5 text-blue-600" />
                  <CardTitle>Tags de Equipamentos</CardTitle>
                </div>
                <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                  <DialogTrigger asChild>
                    <Button 
                      onClick={handleOpenDialog}
                      className="bg-blue-600 hover:bg-blue-700"
                      data-testid="button-create-tag"
                    >
                      <Plus className="h-4 w-4 mr-2" />
                      Nova Tag
                    </Button>
                  </DialogTrigger>
                  <DialogContent>
                    <DialogHeader>
                      <DialogTitle>
                        {editingTag ? "Editar Tag" : "Nova Tag"}
                      </DialogTitle>
                    </DialogHeader>
                    <Form {...tagForm}>
                      <form onSubmit={tagForm.handleSubmit(handleSubmit)} className="space-y-4">
                        <FormField
                          control={tagForm.control}
                          name="name"
                          render={({ field }) => (
                            <FormItem>
                              <FormLabel>Nome</FormLabel>
                              <FormControl>
                                <Input 
                                  placeholder="Ex: Máquina de Café" 
                                  {...field} 
                                  data-testid="input-tag-name"
                                />
                              </FormControl>
                              <FormMessage />
                            </FormItem>
                          )}
                        />
                        <FormField
                          control={tagForm.control}
                          name="description"
                          render={({ field }) => (
                            <FormItem>
                              <FormLabel>Descrição (Opcional)</FormLabel>
                              <FormControl>
                                <Textarea 
                                  placeholder="Descrição da tag" 
                                  {...field} 
                                  data-testid="input-tag-description"
                                />
                              </FormControl>
                              <FormMessage />
                            </FormItem>
                          )}
                        />
                        <div className="flex justify-end gap-2">
                          <Button 
                            type="button" 
                            variant="outline" 
                            onClick={() => setIsDialogOpen(false)}
                            data-testid="button-cancel"
                          >
                            Cancelar
                          </Button>
                          <Button 
                            type="submit"
                            className="bg-blue-600 hover:bg-blue-700"
                            data-testid="button-save-tag"
                          >
                            {editingTag ? "Atualizar" : "Criar"}
                          </Button>
                        </div>
                      </form>
                    </Form>
                  </DialogContent>
                </Dialog>
              </div>
            </CardHeader>
            <CardContent>
              {isLoading ? (
                <div className="text-center py-8 text-gray-500">Carregando...</div>
              ) : equipmentTags.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  Nenhuma tag cadastrada ainda.
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Nome</TableHead>
                      <TableHead>Descrição</TableHead>
                      <TableHead>Módulo</TableHead>
                      <TableHead className="text-right">Ações</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {equipmentTags.map((tag: any) => (
                      <TableRow key={tag.id} data-testid={`row-tag-${tag.id}`}>
                        <TableCell className="font-medium" data-testid={`text-tag-name-${tag.id}`}>
                          {tag.name}
                        </TableCell>
                        <TableCell className="text-gray-600 dark:text-gray-400" data-testid={`text-tag-description-${tag.id}`}>
                          {tag.description || "-"}
                        </TableCell>
                        <TableCell>
                          <Badge 
                            variant={tag.module === 'maintenance' ? 'default' : 'secondary'}
                            className={tag.module === 'maintenance' ? 'bg-purple-600' : 'bg-blue-600'}
                          >
                            {tag.module === 'maintenance' ? 'Manutenção' : 'Limpeza'}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleEdit(tag)}
                              data-testid={`button-edit-tag-${tag.id}`}
                            >
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDelete(tag.id)}
                              data-testid={`button-delete-tag-${tag.id}`}
                            >
                              <Trash2 className="h-4 w-4 text-red-600" />
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
      </main>
    </div>
  );
}
