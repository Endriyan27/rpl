import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../models/menu_item.dart';
import '../services/ml_service.dart';
import '../services/database_service.dart';

class PredictionProvider extends ChangeNotifier {
  List<Prediction> _predictions = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  bool _isTrainingModel = false;

  List<Prediction> get predictions => _predictions;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTrainingModel => _isTrainingModel;

  List<Prediction> get significantPredictions =>
      _predictions.where((p) => p.isSignificant).toList();

  List<Prediction> get criticalAlerts =>
      _predictions.where((p) => p.alertLevel == 'critical').toList();

  Future<void> loadPredictions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dbService = DatabaseService();
      final mlService = MLService();

      // Load menu items from database
      _menuItems = await dbService.getAllMenuItems();

      // Check if we have recent predictions
      final existingPredictions = await dbService.getPredictions();

      if (existingPredictions.isNotEmpty) {
        // Use existing predictions if available
        _predictions = existingPredictions;
      } else {
        // Generate new predictions using ML service
        final startDate = DateTime.now();
        _predictions = await mlService.predictSalesForWeek(
          _menuItems,
          startDate,
        );

        // Save predictions to database
        await dbService.insertPredictions(_predictions);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data prediksi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> trainModel() async {
    _isTrainingModel = true;
    notifyListeners();

    try {
      final dbService = DatabaseService();
      final mlService = MLService();

      // Get historical sales data for training
      final salesData = await dbService.getSalesData(
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

      // Train the model
      await mlService.trainModel(salesData);

      // Clear old predictions
      await dbService.clearPredictions();

      // Generate new predictions
      final startDate = DateTime.now();
      _predictions = await mlService.predictSalesForWeek(_menuItems, startDate);

      // Save new predictions
      await dbService.insertPredictions(_predictions);

      _isTrainingModel = false;
      notifyListeners();
    } catch (e) {
      _isTrainingModel = false;
      _error = 'Gagal melatih model: $e';
      notifyListeners();
    }
  }

  Future<void> refreshPredictions() async {
    await loadPredictions();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Prediction? getPredictionById(String id) {
    try {
      return _predictions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Prediction> getPredictionsByType(PredictionType type) {
    return _predictions.where((p) => p.type == type).toList();
  }

  List<Prediction> getPredictionsForDate(DateTime date) {
    return _predictions.where((p) {
      return p.targetDate.year == date.year &&
          p.targetDate.month == date.month &&
          p.targetDate.day == date.day;
    }).toList();
  }
}
