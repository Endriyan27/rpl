import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/database_service.dart';

class PredictionHistory {
  final String id;
  final Prediction prediction;
  final double? actualSales;
  final double? accuracy;
  final DateTime recordedAt;

  PredictionHistory({
    required this.id,
    required this.prediction,
    this.actualSales,
    this.accuracy,
    required this.recordedAt,
  });

  bool get isAccurate => accuracy != null && accuracy! >= 0.8;

  String get accuracyPercentage {
    if (accuracy == null) return 'Belum ada data';
    return '${(accuracy! * 100).toStringAsFixed(1)}%';
  }

  String get statusText {
    if (accuracy == null) return 'Menunggu';
    if (isAccurate) return 'Akurat';
    return 'Tidak Akurat';
  }
}

class HistoryProvider extends ChangeNotifier {
  List<PredictionHistory> _historyList = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  List<PredictionHistory> get historyList => _historyList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  Future<void> loadHistory({DateTime? start, DateTime? end}) async {
    _isLoading = true;
    _error = null;
    _startDate = start;
    _endDate = end;
    notifyListeners();

    try {
      final dbService = DatabaseService();
      final predictions = await dbService.getPredictions();

      // Create history from predictions with mock actual sales
      _historyList = predictions.map((prediction) {
        // Generate mock actual sales (within +/- 20% of predicted)
        final variance = (prediction.predictedQuantity * 0.2);
        final actualSales = prediction.predictedQuantity +
            (variance * (0.5 - (prediction.id.hashCode % 100) / 100));

        // Calculate accuracy
        final difference =
            (actualSales - prediction.predictedQuantity).abs();
        final accuracy = 1 - (difference / prediction.predictedQuantity);

        return PredictionHistory(
          id: 'history_${prediction.id}',
          prediction: prediction,
          actualSales: actualSales,
          accuracy: accuracy.clamp(0.0, 1.0),
          recordedAt: prediction.predictionDate,
        );
      }).toList();

      // Filter by date if specified
      if (_startDate != null) {
        _historyList = _historyList
            .where((h) => h.recordedAt.isAfter(_startDate!))
            .toList();
      }
      if (_endDate != null) {
        _historyList = _historyList
            .where((h) => h.recordedAt.isBefore(_endDate!))
            .toList();
      }

      // Sort by date (newest first)
      _historyList.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat riwayat: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      _historyList.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menghapus riwayat: $e';
      notifyListeners();
    }
  }

  Future<void> clearAllHistory() async {
    try {
      _historyList.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Gagal menghapus semua riwayat: $e';
      notifyListeners();
    }
  }

  Future<String> exportToCSV() async {
    final buffer = StringBuffer();
    buffer.writeln(
        'Tanggal,Menu,Prediksi,Aktual,Akurasi,Perubahan,Alasan');

    for (final history in _historyList) {
      final p = history.prediction;
      buffer.writeln(
        '${p.targetDate.toString()},${p.menuItemName},${p.predictedQuantity.toStringAsFixed(1)},${history.actualSales?.toStringAsFixed(1) ?? 'N/A'},${history.accuracyPercentage},${p.displayPercentage},${p.reasonsText}',
      );
    }

    return buffer.toString();
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadHistory(start: start, end: end);
  }

  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    loadHistory();
  }

  List<PredictionHistory> get accurateHistories =>
      _historyList.where((h) => h.isAccurate).toList();

  List<PredictionHistory> get inaccurateHistories =>
      _historyList.where((h) => !h.isAccurate && h.accuracy != null).toList();

  double get overallAccuracy {
    if (_historyList.isEmpty) return 0.0;
    final withAccuracy =
        _historyList.where((h) => h.accuracy != null).toList();
    if (withAccuracy.isEmpty) return 0.0;

    final sum =
        withAccuracy.fold(0.0, (sum, h) => sum + (h.accuracy ?? 0.0));
    return sum / withAccuracy.length;
  }
}
