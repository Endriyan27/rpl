enum ModelStatus { optimal, needsRetraining, error, training }

class MLModelInfo {
  final String id;
  final String name;
  final ModelStatus status;
  final double accuracy;
  final double errorRate;
  final DateTime lastTrainingDate;
  final DateTime? lastPredictionDate;
  final int totalPredictions;
  final int correctPredictions;
  final Map<String, dynamic> modelMetrics;
  final String version;

  MLModelInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.accuracy,
    required this.errorRate,
    required this.lastTrainingDate,
    this.lastPredictionDate,
    required this.totalPredictions,
    required this.correctPredictions,
    this.modelMetrics = const {},
    required this.version,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name,
    'accuracy': accuracy,
    'errorRate': errorRate,
    'lastTrainingDate': lastTrainingDate.toIso8601String(),
    'lastPredictionDate': lastPredictionDate?.toIso8601String(),
    'totalPredictions': totalPredictions,
    'correctPredictions': correctPredictions,
    'modelMetrics': modelMetrics,
    'version': version,
  };

  factory MLModelInfo.fromJson(Map<String, dynamic> json) => MLModelInfo(
    id: json['id'],
    name: json['name'],
    status: ModelStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ModelStatus.error,
    ),
    accuracy: json['accuracy']?.toDouble() ?? 0.0,
    errorRate: json['errorRate']?.toDouble() ?? 0.0,
    lastTrainingDate: DateTime.parse(json['lastTrainingDate']),
    lastPredictionDate: json['lastPredictionDate'] != null
        ? DateTime.parse(json['lastPredictionDate'])
        : null,
    totalPredictions: json['totalPredictions'] ?? 0,
    correctPredictions: json['correctPredictions'] ?? 0,
    modelMetrics: Map<String, dynamic>.from(json['modelMetrics'] ?? {}),
    version: json['version'] ?? '1.0.0',
  );

  String get statusText {
    switch (status) {
      case ModelStatus.optimal:
        return 'Optimal';
      case ModelStatus.needsRetraining:
        return 'Perlu Training Ulang';
      case ModelStatus.error:
        return 'Error';
      case ModelStatus.training:
        return 'Sedang Training';
    }
  }

  String get statusColor {
    switch (status) {
      case ModelStatus.optimal:
        return '#4CAF50'; // Green
      case ModelStatus.needsRetraining:
        return '#FF9800'; // Orange
      case ModelStatus.error:
        return '#F44336'; // Red
      case ModelStatus.training:
        return '#2196F3'; // Blue
    }
  }

  String get qualityIndicator {
    if (accuracy >= 0.9) return 'Sangat Baik';
    if (accuracy >= 0.8) return 'Baik';
    if (accuracy >= 0.7) return 'Cukup';
    return 'Perlu Perbaikan';
  }

  String get lastTrainingText {
    final now = DateTime.now();
    final difference = now.difference(lastTrainingDate);

    if (difference.inDays == 0) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${difference.inDays} hari lalu';
    }
  }
}
