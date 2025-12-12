import 'dart:convert';

enum PredictionType { increase, decrease, stable, critical }

enum PredictionReason {
  weather,
  holiday,
  localEvent,
  trend,
  stockIssue,
  seasonality,
  historical,
}

class Prediction {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final PredictionType type;
  final double predictedQuantity;
  final double confidenceLevel; // 0.0 to 1.0
  final double percentageChange;
  final DateTime predictionDate;
  final DateTime targetDate;
  final List<PredictionReason> reasons;
  final String description;
  final Map<String, dynamic> rawMLOutput;
  final bool isSignificant;
  final String? alertLevel; // null, 'warning', 'critical'

  Prediction({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.type,
    required this.predictedQuantity,
    required this.confidenceLevel,
    required this.percentageChange,
    required this.predictionDate,
    required this.targetDate,
    required this.reasons,
    required this.description,
    this.rawMLOutput = const {},
    required this.isSignificant,
    this.alertLevel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuItemId': menuItemId,
    'menuItemName': menuItemName,
    'type': type.name,
    'predictedQuantity': predictedQuantity,
    'confidenceLevel': confidenceLevel,
    'percentageChange': percentageChange,
    'predictionDate': predictionDate.toIso8601String(),
    'targetDate': targetDate.toIso8601String(),
    'reasons': reasons.map((r) => r.name).toList(),
    'description': description,
    'rawMLOutput': rawMLOutput,
    'isSignificant': isSignificant,
    'alertLevel': alertLevel,
  };

  factory Prediction.fromJson(Map<String, dynamic> json) {
    // Handle both database format (snake_case) and JSON format (camelCase)
    final id = json['id'] as String;
    final menuItemId = json['menu_item_id'] ?? json['menuItemId'] as String;
    final menuItemName =
        json['menu_item_name'] ?? json['menuItemName'] as String;
    final typeStr = json['type'] as String;
    final predictedQuantity =
        (json['predicted_quantity'] ?? json['predictedQuantity'])?.toDouble() ??
            0.0;
    final confidenceLevel =
        (json['confidence_level'] ?? json['confidenceLevel'])?.toDouble() ?? 0.0;
    final percentageChange =
        (json['percentage_change'] ?? json['percentageChange'])?.toDouble() ??
            0.0;
    final predictionDate = DateTime.parse(
        json['prediction_date'] ?? json['predictionDate']);
    final targetDate =
        DateTime.parse(json['target_date'] ?? json['targetDate']);
    final description = json['description'] ?? '';
    final isSignificant =
        (json['is_significant'] ?? json['isSignificant']) == 1 ||
            (json['is_significant'] ?? json['isSignificant']) == true;
    final alertLevel = json['alert_level'] ?? json['alertLevel'];

    // Parse reasons from JSON string or list
    List<PredictionReason> reasonsList = [];
    final reasonsData = json['reasons'];
    if (reasonsData is String) {
      // Parse JSON string
      try {
        final decoded = (jsonDecode(reasonsData) as List);
        reasonsList = decoded
            .map(
              (r) => PredictionReason.values.firstWhere(
                (pr) => pr.name == r,
                orElse: () => PredictionReason.historical,
              ),
            )
            .toList();
      } catch (e) {
        reasonsList = [PredictionReason.historical];
      }
    } else if (reasonsData is List) {
      reasonsList = reasonsData
          .map(
            (r) => PredictionReason.values.firstWhere(
              (pr) => pr.name == r,
              orElse: () => PredictionReason.historical,
            ),
          )
          .toList();
    }

    // Parse raw ML output
    Map<String, dynamic> rawOutput = {};
    final rawMLData = json['raw_ml_output'] ?? json['rawMLOutput'];
    if (rawMLData is String) {
      try {
        rawOutput = Map<String, dynamic>.from(jsonDecode(rawMLData));
      } catch (e) {
        rawOutput = {};
      }
    } else if (rawMLData is Map) {
      rawOutput = Map<String, dynamic>.from(rawMLData);
    }

    return Prediction(
      id: id,
      menuItemId: menuItemId,
      menuItemName: menuItemName,
      type: PredictionType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => PredictionType.stable,
      ),
      predictedQuantity: predictedQuantity,
      confidenceLevel: confidenceLevel,
      percentageChange: percentageChange,
      predictionDate: predictionDate,
      targetDate: targetDate,
      reasons: reasonsList,
      description: description,
      rawMLOutput: rawOutput,
      isSignificant: isSignificant,
      alertLevel: alertLevel,
    );
  }

  String get statusColor {
    switch (type) {
      case PredictionType.increase:
        return '#4CAF50'; // Green
      case PredictionType.decrease:
        return '#FF5722'; // Red
      case PredictionType.critical:
        return '#F44336'; // Dark Red
      case PredictionType.stable:
        return '#2196F3'; // Blue
    }
  }

  String get displayPercentage {
    final sign = percentageChange >= 0 ? '+' : '';
    return '$sign${percentageChange.toStringAsFixed(1)}%';
  }

  String get reasonsText {
    if (reasons.isEmpty) return 'Analisis historis';

    return reasons
        .map((reason) {
          switch (reason) {
            case PredictionReason.weather:
              return 'Cuaca';
            case PredictionReason.holiday:
              return 'Hari libur';
            case PredictionReason.localEvent:
              return 'Event lokal';
            case PredictionReason.trend:
              return 'Trend historis';
            case PredictionReason.stockIssue:
              return 'Masalah stok';
            case PredictionReason.seasonality:
              return 'Musiman';
            case PredictionReason.historical:
              return 'Data historis';
          }
        })
        .join(', ');
  }
}
