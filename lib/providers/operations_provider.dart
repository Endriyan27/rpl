import 'package:flutter/material.dart';
import '../models/ml_model_info.dart';
import '../services/database_service.dart';
import '../services/ml_service.dart';

class MonthlySales {
  final int month;
  final int year;
  final double totalSales;
  final int totalOrders;
  final String monthName;

  MonthlySales({
    required this.month,
    required this.year,
    required this.totalSales,
    required this.totalOrders,
    required this.monthName,
  });
}

class DashboardMetrics {
  final double totalSalesYTD;
  final double salesGrowthPercentage;
  final double averageOrdersPerDay;
  final double ordersGrowthPercentage;
  final List<MonthlySales> monthlySales;
  final MLModelInfo modelInfo;
  final DateTime lastUpdated;

  DashboardMetrics({
    required this.totalSalesYTD,
    required this.salesGrowthPercentage,
    required this.averageOrdersPerDay,
    required this.ordersGrowthPercentage,
    required this.monthlySales,
    required this.modelInfo,
    required this.lastUpdated,
  });
}

class OperationsProvider extends ChangeNotifier {
  DashboardMetrics? _metrics;
  bool _isLoading = false;
  String? _error;
  bool _isTrainingModel = false;

  DashboardMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTrainingModel => _isTrainingModel;

  Future<void> loadOperationalData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dbService = DatabaseService();

      // Get sales data for metrics calculation
      final salesData = await dbService.getSalesData(
        startDate: DateTime(DateTime.now().year, 1, 1),
        endDate: DateTime.now(),
      );

      // Calculate metrics
      final totalSales =
          salesData.fold(0.0, (sum, sale) => sum + sale.totalAmount);
      final totalOrders = salesData.length;
      final daysYTD = DateTime.now().difference(
        DateTime(DateTime.now().year, 1, 1),
      ).inDays + 1;
      final avgOrdersPerDay = totalOrders / daysYTD;

      // Generate monthly sales data
      final monthlySales = _generateMonthlySales(salesData);

      // Get model info
      final lastTraining = await dbService.getSetting('last_model_training');
      final modelVersion = await dbService.getSetting('model_version');

      final modelInfo = MLModelInfo(
        id: 'hokben_ann_v1',
        name: 'Model ANN Hokben',
        status: ModelStatus.optimal,
        accuracy: 0.92,
        errorRate: 0.02,
        lastTrainingDate: lastTraining != null
            ? DateTime.parse(lastTraining)
            : DateTime.now().subtract(const Duration(hours: 2)),
        lastPredictionDate: DateTime.now().subtract(
          const Duration(minutes: 30),
        ),
        totalPredictions: 1247,
        correctPredictions: 1147,
        version: modelVersion ?? '1.2.3',
        modelMetrics: {
          'mae': 0.08,
          'rmse': 0.12,
          'precision': 0.94,
          'recall': 0.89,
          'features': 12,
        },
      );

      _metrics = DashboardMetrics(
        totalSalesYTD: totalSales,
        salesGrowthPercentage: 8.5, // Mock growth percentage
        averageOrdersPerDay: avgOrdersPerDay,
        ordersGrowthPercentage: 2.1, // Mock growth percentage
        monthlySales: monthlySales,
        modelInfo: modelInfo,
        lastUpdated: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data operasional: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MonthlySales> _generateMonthlySales(List salesData) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
    final currentMonth = DateTime.now().month;
    final List<MonthlySales> result = [];

    for (int i = 0; i < (currentMonth <= 6 ? currentMonth : 6); i++) {
      final monthData = salesData.where((sale) {
        final saleDate = DateTime.parse(sale.date);
        return saleDate.month == i + 1;
      }).toList();

      final totalSales =
          monthData.fold(0.0, (sum, sale) => sum + sale.totalAmount);
      final totalOrders = monthData.length;

      result.add(MonthlySales(
        month: i + 1,
        year: DateTime.now().year,
        totalSales: totalSales,
        totalOrders: totalOrders,
        monthName: months[i],
      ));
    }

    // If we don't have data for some months, fill with dummy data
    if (result.length < 6) {
      final dummySales = [95000, 105000, 98000, 115000, 108000, 125000];
      final dummyOrders = [280, 320, 290, 350, 330, 380];

      for (int i = result.length; i < 6; i++) {
        result.add(MonthlySales(
          month: i + 1,
          year: DateTime.now().year,
          totalSales: dummySales[i].toDouble(),
          totalOrders: dummyOrders[i],
          monthName: months[i],
        ));
      }
    }

    return result;
  }

  Future<void> trainModel() async {
    _isTrainingModel = true;
    notifyListeners();

    try {
      final dbService = DatabaseService();
      final mlService = MLService();

      // Get historical data
      final salesData = await dbService.getSalesData(
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

      // Train model
      await mlService.trainModel(salesData);

      // Update last training time
      await dbService.setSetting(
        'last_model_training',
        DateTime.now().toIso8601String(),
      );

      // Reload data
      await loadOperationalData();

      _isTrainingModel = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal melatih model: $e';
      _isTrainingModel = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadOperationalData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
