import { ModernCard, ModernCardContent, ModernCardHeader } from "@/components/ui/modern-card";
import { ModernPageHeader } from "@/components/ui/modern-page-header";
import { useModuleTheme } from "@/hooks/use-module-theme";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { useQuery } from "@tanstack/react-query";
import { useState, useEffect, useMemo } from "react";
import { useModule } from "@/contexts/ModuleContext";
import { useLocation } from "wouter";
import { cn } from "@/lib/utils";
import { 
  FileBarChart, 
  DollarSign,
  TrendingUp,
  Building2,
  MapPin,
  Download
} from "lucide-react";

interface AssetReportProps {
  customerId: string;
}

export default function AssetReport({ customerId }: AssetReportProps) {
  const { currentModule } = useModule();
  const theme = useModuleTheme();
  const [, setLocation] = useLocation();

  // Redirect if not in maintenance module
  useEffect(() => {
    if (currentModule !== 'maintenance') {
      setLocation('/');
    }
  }, [currentModule, setLocation]);

  // Fetch equipment
  const { data: equipment, isLoading: isLoadingEquipment } = useQuery({
    queryKey: [`/api/customers/${customerId}/equipment`],
    enabled: !!customerId,
  });

  // Fetch sites
  const { data: sites } = useQuery({
    queryKey: [`/api/customers/${customerId}/sites`, { module: currentModule }],
    enabled: !!customerId,
  });

  // Fetch zones
  const { data: zones } = useQuery({
    queryKey: [`/api/customers/${customerId}/zones`, { module: currentModule }],
    enabled: !!customerId,
  });

  // Calculate totals and group by site and zone
  const reportData = useMemo(() => {
    if (!Array.isArray(equipment) || !Array.isArray(sites) || !Array.isArray(zones)) {
      return { totalValue: 0, siteTotals: [], grandTotal: 0 };
    }

    let grandTotal = 0;
    const siteTotals: any[] = [];

    sites.forEach((site: any) => {
      const siteEquipment = equipment.filter((eq: any) => eq.siteId === site.id);
      const siteZones = zones.filter((z: any) => z.siteId === site.id);
      
      const zoneTotals: any[] = [];
      let siteTotal = 0;

      // Group by zone
      siteZones.forEach((zone: any) => {
        const zoneEquipment = siteEquipment.filter((eq: any) => eq.zoneId === zone.id);
        const zoneTotal = zoneEquipment.reduce((sum: number, eq: any) => {
          const value = parseFloat(eq.value) || 0;
          return sum + value;
        }, 0);

        if (zoneEquipment.length > 0) {
          zoneTotals.push({
            zoneName: zone.name,
            equipmentCount: zoneEquipment.length,
            totalValue: zoneTotal,
            equipment: zoneEquipment
          });
          siteTotal += zoneTotal;
        }
      });

      // Equipment without zone
      const noZoneEquipment = siteEquipment.filter((eq: any) => !eq.zoneId);
      if (noZoneEquipment.length > 0) {
        const noZoneTotal = noZoneEquipment.reduce((sum: number, eq: any) => {
          const value = parseFloat(eq.value) || 0;
          return sum + value;
        }, 0);

        zoneTotals.push({
          zoneName: 'Sem Zona Definida',
          equipmentCount: noZoneEquipment.length,
          totalValue: noZoneTotal,
          equipment: noZoneEquipment
        });
        siteTotal += noZoneTotal;
      }

      if (zoneTotals.length > 0) {
        siteTotals.push({
          siteName: site.name,
          equipmentCount: siteEquipment.length,
          totalValue: siteTotal,
          zones: zoneTotals
        });
        grandTotal += siteTotal;
      }
    });

    return { siteTotals, grandTotal };
  }, [equipment, sites, zones]);

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value);
  };

  const totalEquipment = Array.isArray(equipment) ? equipment.length : 0;
  const equipmentWithValue = Array.isArray(equipment) 
    ? equipment.filter((eq: any) => eq.value && parseFloat(eq.value) > 0).length 
    : 0;

  return (
    <>
      <ModernPageHeader 
        title="Relatório de Patrimônio"
        description="Visualize o valor total dos equipamentos por local e zona"
        icon={FileBarChart}
        stats={[
          { 
            label: "Total de Equipamentos", 
            value: totalEquipment,
            icon: Building2
          },
          {
            label: "Com Valor Cadastrado",
            value: equipmentWithValue,
            icon: TrendingUp
          },
          {
            label: "Valor Total do Patrimônio",
            value: formatCurrency(reportData.grandTotal),
            icon: DollarSign
          }
        ]}
        actions={
          <Button 
            variant="outline" 
            className={theme.buttons.outline}
            onClick={() => window.print()}
            data-testid="button-export-report"
          >
            <Download className="w-4 h-4 mr-2" />
            Exportar
          </Button>
        }
      />
      <div className={cn("flex-1 overflow-y-auto p-4 md:p-6 space-y-6", theme.gradients.section)}>
        {isLoadingEquipment ? (
          <div className="text-center py-8">
            <div className="w-16 h-16 border-4 border-orange-100 border-t-orange-600 rounded-full animate-spin mx-auto"></div>
            <p className="mt-4 text-gray-600">Carregando relatório...</p>
          </div>
        ) : reportData.siteTotals.length === 0 ? (
          <ModernCard variant="gradient">
            <ModernCardContent>
              <div className="text-center py-12">
                <FileBarChart className="w-16 h-16 mx-auto text-gray-300 mb-4" />
                <p className="text-gray-500 text-lg font-medium">Nenhum equipamento com valor cadastrado</p>
                <p className="text-gray-400 text-sm mt-1">Cadastre equipamentos e seus valores para gerar o relatório</p>
              </div>
            </ModernCardContent>
          </ModernCard>
        ) : (
          <div className="space-y-6">
            {reportData.siteTotals.map((site: any, siteIndex: number) => (
              <ModernCard key={siteIndex} variant="glass">
                <ModernCardHeader icon={<Building2 className="w-6 h-6" />}>
                  <div className="flex items-center justify-between flex-1">
                    <div>
                      <h3 className="text-lg font-semibold">{site.siteName}</h3>
                      <p className="text-sm text-gray-500">
                        {site.equipmentCount} equipamento(s)
                      </p>
                    </div>
                    <Badge className="inline-flex items-center rounded-full font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-primary text-primary-foreground hover:bg-primary/80 text-lg px-4 py-2 border pl-[20px] pr-[20px] ml-[10px] mr-[10px]">
                      {formatCurrency(site.totalValue)}
                    </Badge>
                  </div>
                </ModernCardHeader>
                <ModernCardContent>
                  <div className="space-y-4">
                    {site.zones.map((zone: any, zoneIndex: number) => (
                      <div key={zoneIndex} className="border-l-4 border-orange-400 pl-4 py-2 bg-orange-50/50 rounded-r-lg">
                        <div className="flex items-center justify-between mb-3">
                          <div className="flex items-center gap-2">
                            <MapPin className="w-4 h-4 text-orange-600" />
                            <h4 className="font-semibold text-gray-800">{zone.zoneName}</h4>
                            <Badge variant="outline" className="text-xs">
                              {zone.equipmentCount} item(ns)
                            </Badge>
                          </div>
                          <span className="text-lg font-bold text-orange-600">
                            {formatCurrency(zone.totalValue)}
                          </span>
                        </div>
                        
                        <Table>
                          <TableHeader>
                            <TableRow>
                              <TableHead>Equipamento</TableHead>
                              <TableHead>Tipo</TableHead>
                              <TableHead>Fabricante</TableHead>
                              <TableHead>Modelo</TableHead>
                              <TableHead className="text-right">Valor</TableHead>
                            </TableRow>
                          </TableHeader>
                          <TableBody>
                            {zone.equipment.map((equip: any) => (
                              <TableRow key={equip.id}>
                                <TableCell className="font-medium">{equip.name}</TableCell>
                                <TableCell>{equip.equipmentType || 'N/A'}</TableCell>
                                <TableCell>{equip.manufacturer || 'N/A'}</TableCell>
                                <TableCell>{equip.model || 'N/A'}</TableCell>
                                <TableCell className="text-right font-semibold">
                                  {formatCurrency(parseFloat(equip.value) || 0)}
                                </TableCell>
                              </TableRow>
                            ))}
                          </TableBody>
                        </Table>
                      </div>
                    ))}
                  </div>
                </ModernCardContent>
              </ModernCard>
            ))}

            {/* Grand Total Card */}
            <ModernCard variant="featured">
              <ModernCardContent>
                <div className="flex items-center justify-between py-4">
                  <div className="flex items-center gap-3">
                    <DollarSign className="w-8 h-8 text-white" />
                    <div>
                      <h3 className="text-xl font-bold text-white">Valor Total do Patrimônio</h3>
                      <p className="text-white/80 text-sm">
                        {totalEquipment} equipamento(s) cadastrado(s)
                      </p>
                    </div>
                  </div>
                  <div className="text-3xl font-bold text-white">
                    {formatCurrency(reportData.grandTotal)}
                  </div>
                </div>
              </ModernCardContent>
            </ModernCard>
          </div>
        )}
      </div>
    </>
  );
}
