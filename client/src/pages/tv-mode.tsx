import { useEffect, useState } from "react";
import { useClient } from "@/contexts/ClientContext";
import { useModule } from "@/contexts/ModuleContext";
import { useQuery } from "@tanstack/react-query";
import ReactApexChart from "react-apexcharts";
import { ApexOptions } from "apexcharts";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Trophy, Medal, Award, TrendingUp, Activity } from "lucide-react";
import { motion } from "framer-motion";

interface TvModeStats {
  workOrdersStats: {
    resolved: number;
    unresolved: number;
    total: number;
  };
  leaderboard: Array<{
    userId: string;
    userName: string;
    userEmail: string;
    completedCount: number;
  }>;
}

export default function TvMode() {
  const { activeClientId } = useClient();
  const { currentModule } = useModule();
  const [refreshKey, setRefreshKey] = useState(0);

  // Fetch TV Mode stats
  const { data: stats, isLoading } = useQuery<TvModeStats>({
    queryKey: ["/api/tv-mode/stats", activeClientId, currentModule, refreshKey],
    enabled: !!activeClientId && !!currentModule,
    refetchInterval: 10000, // Auto-refresh every 10 seconds
  });

  // Auto-refresh key updater
  useEffect(() => {
    const interval = setInterval(() => {
      setRefreshKey((prev) => prev + 1);
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  // Chart configuration for work orders
  const workOrdersChartOptions: ApexOptions = {
    chart: {
      type: "donut",
      animations: {
        enabled: true,
        dynamicAnimation: {
          enabled: true,
          speed: 1000,
        },
      },
    },
    labels: ["OSs Resolvidas", "OSs Não Resolvidas"],
    colors: ["#10b981", "#ef4444"],
    legend: {
      position: "bottom",
      fontSize: "16px",
      labels: {
        colors: "#ffffff",
      },
    },
    dataLabels: {
      enabled: true,
      style: {
        fontSize: "18px",
        fontWeight: "bold",
        colors: ["#ffffff"],
      },
    },
    plotOptions: {
      pie: {
        donut: {
          size: "70%",
          labels: {
            show: true,
            total: {
              show: true,
              label: "Total de OSs",
              fontSize: "20px",
              fontWeight: "bold",
              color: "#ffffff",
              formatter: () => String(stats?.workOrdersStats.total || 0),
            },
          },
        },
      },
    },
    responsive: [
      {
        breakpoint: 480,
        options: {
          chart: {
            width: 300,
          },
          legend: {
            position: "bottom",
          },
        },
      },
    ],
  };

  const workOrdersChartSeries = [
    stats?.workOrdersStats.resolved || 0,
    stats?.workOrdersStats.unresolved || 0,
  ];

  // Get medal icon based on rank
  const getMedalIcon = (rank: number) => {
    if (rank === 1) return <Trophy className="w-8 h-8 text-yellow-400" />;
    if (rank === 2) return <Medal className="w-8 h-8 text-gray-400" />;
    if (rank === 3) return <Award className="w-8 h-8 text-amber-600" />;
    return <TrendingUp className="w-6 h-6 text-blue-400" />;
  };

  // Get rank color
  const getRankColor = (rank: number) => {
    if (rank === 1) return "from-yellow-500 to-yellow-600";
    if (rank === 2) return "from-gray-400 to-gray-500";
    if (rank === 3) return "from-amber-600 to-amber-700";
    return "from-blue-500 to-blue-600";
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
        <div className="text-center">
          <Activity className="w-16 h-16 text-primary animate-pulse mx-auto mb-4" />
          <p className="text-xl text-white">Carregando dados em tempo real...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="text-center mb-8"
      >
        <h1 className="text-5xl font-bold text-white mb-2">
          Dashboard TV Mode
        </h1>
        <p className="text-xl text-slate-300">
          Atualização automática a cada 10 segundos
        </p>
        <Badge variant="outline" className="mt-4 text-lg px-4 py-2 border-green-400 text-green-400">
          <Activity className="w-4 h-4 mr-2 animate-pulse" />
          Ao Vivo
        </Badge>
      </motion.div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-7xl mx-auto">
        {/* Work Orders Chart */}
        <motion.div
          initial={{ opacity: 0, x: -50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6 }}
        >
          <Card className="bg-slate-800/50 border-slate-700 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="text-3xl text-white flex items-center gap-2">
                <TrendingUp className="w-8 h-8 text-primary" />
                Ordens de Serviço
              </CardTitle>
            </CardHeader>
            <CardContent>
              <ReactApexChart
                options={workOrdersChartOptions}
                series={workOrdersChartSeries}
                type="donut"
                height={400}
              />
              <div className="grid grid-cols-2 gap-4 mt-6">
                <div className="bg-green-500/20 border border-green-500 rounded-lg p-4 text-center">
                  <p className="text-green-400 text-sm font-medium mb-1">Resolvidas</p>
                  <p className="text-4xl font-bold text-white">
                    {stats?.workOrdersStats.resolved || 0}
                  </p>
                </div>
                <div className="bg-red-500/20 border border-red-500 rounded-lg p-4 text-center">
                  <p className="text-red-400 text-sm font-medium mb-1">Não Resolvidas</p>
                  <p className="text-4xl font-bold text-white">
                    {stats?.workOrdersStats.unresolved || 0}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* Leaderboard */}
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.6 }}
        >
          <Card className="bg-slate-800/50 border-slate-700 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="text-3xl text-white flex items-center gap-2">
                <Trophy className="w-8 h-8 text-yellow-400" />
                Top Colaboradores
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {stats?.leaderboard && stats.leaderboard.length > 0 ? (
                  stats.leaderboard.map((collaborator, index) => (
                    <motion.div
                      key={collaborator.userId}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className={`bg-gradient-to-r ${getRankColor(index + 1)} p-4 rounded-lg shadow-lg`}
                      data-testid={`leaderboard-item-${index + 1}`}
                    >
                      <div className="flex items-center gap-4">
                        {/* Rank & Medal */}
                        <div className="flex flex-col items-center justify-center">
                          {getMedalIcon(index + 1)}
                          <Badge
                            variant="secondary"
                            className="mt-1 text-xs font-bold bg-white/90 text-slate-900"
                          >
                            #{index + 1}
                          </Badge>
                        </div>

                        {/* User Info */}
                        <div className="flex-1">
                          <h3 className="text-xl font-bold text-white">
                            {collaborator.userName}
                          </h3>
                          <p className="text-sm text-white/80">
                            {collaborator.userEmail}
                          </p>
                        </div>

                        {/* Score */}
                        <div className="text-right">
                          <p className="text-4xl font-bold text-white">
                            {collaborator.completedCount}
                          </p>
                          <p className="text-sm text-white/80">OSs Concluídas</p>
                        </div>
                      </div>
                    </motion.div>
                  ))
                ) : (
                  <div className="text-center py-12">
                    <Trophy className="w-16 h-16 text-slate-600 mx-auto mb-4" />
                    <p className="text-slate-400 text-lg">
                      Nenhum colaborador com OSs concluídas ainda.
                    </p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* Auto-refresh indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.8 }}
        className="text-center mt-8"
      >
        <p className="text-slate-500 text-sm">
          Última atualização: {new Date().toLocaleTimeString("pt-BR")}
        </p>
      </motion.div>
    </div>
  );
}
