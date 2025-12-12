import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/operations_provider.dart';
import '../widgets/monthly_sales_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/model_status_card.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationsProvider>().loadOperationalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard Operasional',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OperationsProvider>().refreshData();
            },
          ),
        ],
      ),
      body: Consumer<OperationsProvider>(
        builder: (context, opsProvider, child) {
          if (opsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (opsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    opsProvider.error!,
                    style: TextStyle(fontSize: 16, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => opsProvider.loadOperationalData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (opsProvider.metrics == null) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          }

          final metrics = opsProvider.metrics!;

          return RefreshIndicator(
            onRefresh: () => opsProvider.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Total Penjualan (YTD)',
                          value: currencyFormat.format(metrics.totalSalesYTD),
                          trend: metrics.salesGrowthPercentage,
                          icon: Icons.attach_money,
                          iconColor: const Color(0xFF00D05E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Rata-rata Order/Hari',
                          value: metrics.averageOrdersPerDay
                              .toStringAsFixed(0),
                          trend: metrics.ordersGrowthPercentage,
                          icon: Icons.shopping_cart,
                          iconColor: const Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Monthly Sales Chart
                  const Text(
                    'Penjualan Bulanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MonthlySalesChart(
                    monthlySales: metrics.monthlySales,
                  ),
                  const SizedBox(height: 24),

                  // Model Status
                  const Text(
                    'Status Sistem Cerdas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ModelStatusCard(
                    modelInfo: metrics.modelInfo,
                    onRetrain: () => opsProvider.trainModel(),
                    isTraining: opsProvider.isTrainingModel,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
