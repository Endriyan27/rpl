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

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
    id: json['id'],
    menuItemId: json['menuItemId'],
    menuItemName: json['menuItemName'],
    type: PredictionType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => PredictionType.stable,
    ),
    predictedQuantity: json['predictedQuantity']?.toDouble() ?? 0.0,
    confidenceLevel: json['confidenceLevel']?.toDouble() ?? 0.0,
    percentageChange: json['percentageChange']?.toDouble() ?? 0.0,
    predictionDate: DateTime.parse(json['predictionDate']),
    targetDate: DateTime.parse(json['targetDate']),
    reasons:
        (json['reasons'] as List?)
            ?.map(
              (r) => PredictionReason.values.firstWhere(
                (pr) => pr.name == r,
                orElse: () => PredictionReason.historical,
              ),
            )
            .toList() ??
        [],
    description: json['description'] ?? '',
    rawMLOutput: Map<String, dynamic>.from(json['rawMLOutput'] ?? {}),
    isSignificant: json['isSignificant'] ?? false,
    alertLevel: json['alertLevel'],
  );

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
