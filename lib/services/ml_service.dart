import 'dart:math';
import '../models/sales_data.dart';
import '../models/prediction.dart';
import '../models/menu_item.dart';

class MLService {
  static const int _inputFeatures = 12;
  static const int _hiddenNodes = 20;
  static const int _outputNodes = 1;

  // Simple neural network weights (in a real app, these would be loaded from a trained model)
  late List<List<double>> _weightsInputHidden;
  late List<double> _weightsHiddenOutput;
  late List<double> _biasHidden;
  late double _biasOutput;

  bool _isModelTrained = false;
  double _accuracy = 0.92;

  MLService() {
    _initializeWeights();
  }

  void _initializeWeights() {
    final random = Random(42); // Fixed seed for consistency

    // Initialize input to hidden weights
    _weightsInputHidden = List.generate(
      _inputFeatures,
      (i) =>
          List.generate(_hiddenNodes, (j) => (random.nextDouble() - 0.5) * 2),
    );

    // Initialize hidden to output weights
    _weightsHiddenOutput = List.generate(
      _hiddenNodes,
      (i) => (random.nextDouble() - 0.5) * 2,
    );

    // Initialize biases
    _biasHidden = List.generate(
      _hiddenNodes,
      (i) => (random.nextDouble() - 0.5) * 2,
    );
    _biasOutput = (random.nextDouble() - 0.5) * 2;

    _isModelTrained = true;
  }

  Future<List<Prediction>> predictSalesForWeek(
    List<MenuItem> menuItems,
    DateTime startDate,
  ) async {
    if (!_isModelTrained) {
      throw Exception('Model not trained yet');
    }

    final predictions = <Prediction>[];

    for (final menuItem in menuItems) {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final targetDate = startDate.add(Duration(days: dayOffset));

        final features = _generateFeatures(menuItem, targetDate);
        final predictedQuantity = await _predict(features);

        final prediction = _createPrediction(
          menuItem,
          targetDate,
          predictedQuantity,
        );

        predictions.add(prediction);
      }
    }

    return predictions;
  }

  List<double> _generateFeatures(MenuItem menuItem, DateTime date) {
    // Generate 12 features based on the ANN specification
    return [
      date.weekday.toDouble(), // Day of week (1-7)
      date.day.toDouble(), // Day of month (1-31)
      date.month.toDouble(), // Month (1-12)
      date.year.toDouble() - 2020, // Year offset
      _getTemperature(date), // Temperature
      _isHoliday(date) ? 1.0 : 0.0, // Holiday flag
      _isLocalEvent(date) ? 1.0 : 0.0, // Local event flag
      _getHistoricalAverage(menuItem), // Historical average
      menuItem.price, // Menu price
      _getWeatherScore(date), // Weather score
      _getSeasonality(date), // Seasonality factor
      _getTrend(menuItem, date), // Trend factor
    ];
  }

  Future<double> _predict(List<double> features) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 10));

    // Forward pass through the neural network

    // Input to hidden layer
    final hiddenLayer = List.generate(_hiddenNodes, (i) {
      double sum = _biasHidden[i];
      for (int j = 0; j < _inputFeatures; j++) {
        sum += features[j] * _weightsInputHidden[j][i];
      }
      return _sigmoid(sum);
    });

    // Hidden to output layer
    double output = _biasOutput;
    for (int i = 0; i < _hiddenNodes; i++) {
      output += hiddenLayer[i] * _weightsHiddenOutput[i];
    }

    // Apply sigmoid and scale to reasonable quantity range
    final normalizedOutput = _sigmoid(output);
    return normalizedOutput * 100; // Scale to 0-100 quantity range
  }

  double _sigmoid(double x) {
    return 1.0 / (1.0 + exp(-x));
  }

  Prediction _createPrediction(
    MenuItem menuItem,
    DateTime targetDate,
    double predictedQuantity,
  ) {
    final now = DateTime.now();
    final random = Random();

    // Determine prediction type based on predicted quantity
    PredictionType type;
    double percentageChange;
    List<PredictionReason> reasons = [];
    String? alertLevel;
    bool isSignificant = false;

    // Generate mock historical average for comparison
    final historicalAverage = _getHistoricalAverage(menuItem);
    percentageChange =
        ((predictedQuantity - historicalAverage) / historicalAverage) * 100;

    if (percentageChange > 15) {
      type = PredictionType.increase;
      isSignificant = true;
      reasons.add(PredictionReason.localEvent);
    } else if (percentageChange < -15) {
      type = PredictionType.decrease;
      isSignificant = true;
      reasons.add(PredictionReason.stockIssue);
    } else if (predictedQuantity < 20) {
      type = PredictionType.critical;
      alertLevel = 'critical';
      isSignificant = true;
      reasons.add(PredictionReason.stockIssue);
    } else {
      type = PredictionType.stable;
      reasons.add(PredictionReason.historical);
    }

    // Add weather reason if it affects prediction
    if (_getWeatherScore(targetDate) < 0.5) {
      reasons.add(PredictionReason.weather);
    }

    final confidence = _accuracy + (random.nextDouble() * 0.08 - 0.04);

    return Prediction(
      id: 'pred_${menuItem.id}_${targetDate.millisecondsSinceEpoch}',
      menuItemId: menuItem.id,
      menuItemName: menuItem.name,
      type: type,
      predictedQuantity: predictedQuantity,
      confidenceLevel: confidence.clamp(0.7, 0.98),
      percentageChange: percentageChange,
      predictionDate: now,
      targetDate: targetDate,
      reasons: reasons,
      description: _generateDescription(
        type,
        menuItem.name,
        percentageChange,
        targetDate,
      ),
      isSignificant: isSignificant,
      alertLevel: alertLevel,
      rawMLOutput: {
        'predicted_quantity': predictedQuantity,
        'confidence': confidence,
        'features_used': _inputFeatures,
      },
    );
  }

  String _generateDescription(
    PredictionType type,
    String menuName,
    double percentageChange,
    DateTime targetDate,
  ) {
    final dateText = _getDateText(targetDate);

    switch (type) {
      case PredictionType.increase:
        return 'Diprediksi naik ${percentageChange.abs().toStringAsFixed(1)}% pada $dateText karena faktor positif';
      case PredictionType.decrease:
        return 'Diprediksi turun ${percentageChange.abs().toStringAsFixed(1)}% pada $dateText';
      case PredictionType.critical:
        return 'Permintaan tinggi diprediksi turun drastis. Pastikan stok bahan baku aman';
      case PredictionType.stable:
        return 'Penjualan stabil dengan sedikit peningkatan';
    }
  }

  String _getDateText(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'hari ini';
    if (difference == 1) return 'besok';
    if (difference == 2) return 'lusa';
    return 'hari ${_getDayName(date.weekday)}';
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  // Helper methods for feature generation
  double _getTemperature(DateTime date) {
    // Simulate temperature based on date
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return 25 + 5 * sin((dayOfYear / 365.0) * 2 * pi);
  }

  bool _isHoliday(DateTime date) {
    // Simple holiday detection (weekends and some fixed dates)
    return date.weekday >= 6 ||
        (date.month == 12 && date.day == 25) ||
        (date.month == 1 && date.day == 1);
  }

  bool _isLocalEvent(DateTime date) {
    // Mock local event detection
    return date.day % 15 == 0; // Every 15th day has a local event
  }

  double _getHistoricalAverage(MenuItem menuItem) {
    // Mock historical averages based on menu type
    switch (menuItem.category.toLowerCase()) {
      case 'bento':
        return 65.0;
      case 'rice bowl':
        return 45.0;
      default:
        return 50.0;
    }
  }

  double _getWeatherScore(DateTime date) {
    // Mock weather score (0-1, where 1 is perfect weather)
    final temp = _getTemperature(date);
    if (temp >= 20 && temp <= 30) return 1.0;
    if (temp >= 15 && temp <= 35) return 0.7;
    return 0.4;
  }

  double _getSeasonality(DateTime date) {
    // Seasonal factor based on month
    final seasonalFactors = [
      0.8,
      0.7,
      0.9,
      1.0,
      1.1,
      1.2,
      1.2,
      1.1,
      1.0,
      0.9,
      0.8,
      0.9,
    ];
    return seasonalFactors[date.month - 1];
  }

  double _getTrend(MenuItem menuItem, DateTime date) {
    // Mock trend calculation
    final daysSinceEpoch = date.difference(DateTime(2020, 1, 1)).inDays;
    return 1.0 + (daysSinceEpoch / 1000.0); // Slight upward trend over time
  }

  Future<void> trainModel(List<SalesData> trainingData) async {
    // Simulate model training
    await Future.delayed(const Duration(seconds: 3));

    _initializeWeights();
    _accuracy = 0.92 + Random().nextDouble() * 0.06; // 0.92 to 0.98
    _isModelTrained = true;
  }

  bool get isModelTrained => _isModelTrained;
  double get modelAccuracy => _accuracy;
}
