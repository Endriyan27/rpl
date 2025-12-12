import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/ml_model_info.dart';
import '../services/database_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardMetrics? _metrics;
  bool _isLoading = false;
  String? _error;

  DashboardMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Generate mock dashboard data
      final monthlySales = _generateMonthlySales();
      final modelInfo = _generateMLModelInfo();

      _metrics = DashboardMetrics(
        totalSalesYTD: 1200000.0, // 1.2M
        salesGrowthPercentage: 8.5,
        averageOrdersPerDay: 340.0,
        ordersGrowthPercentage: 2.1,
        monthlySales: monthlySales,
        modelInfo: modelInfo,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data dashboard';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MonthlySales> _generateMonthlySales() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
    final salesData = [95000, 105000, 98000, 115000, 108000, 125000];
    final orderData = [280, 320, 290, 350, 330, 380];

    return List.generate(months.length, (index) {
      return MonthlySales(
        month: index + 1,
        year: 2023,
        totalSales: salesData[index].toDouble(),
        totalOrders: orderData[index],
        monthName: months[index],
      );
    });
  }

  MLModelInfo _generateMLModelInfo() {
    return MLModelInfo(
      id: 'hokben_ann_v1',
      name: 'Model ANN Hokben',
      status: ModelStatus.optimal,
      accuracy: 0.92,
      errorRate: 0.02,
      lastTrainingDate: DateTime.now().subtract(const Duration(hours: 2)),
      lastPredictionDate: DateTime.now().subtract(const Duration(minutes: 30)),
      totalPredictions: 1247,
      correctPredictions: 1147,
      version: '1.2.3',
      modelMetrics: {
        'mae': 0.08,
        'rmse': 0.12,
        'precision': 0.94,
        'recall': 0.89,
      },
    );
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
