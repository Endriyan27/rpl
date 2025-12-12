import 'package:flutter/material.dart';
import '../models/prediction.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback? onTap;

  const PredictionCard({super.key, required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (prediction.alertLevel != null) ...[
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: prediction.alertLevel == 'critical'
                          ? Colors.red
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    prediction.displayPercentage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                prediction.menuItemName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                prediction.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(prediction.targetDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Akurasi ${(prediction.confidenceLevel * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Reasons
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: prediction.reasons
                    .map(
                      (reason) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getReasonText(reason),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    return Color(int.parse(prediction.statusColor.replaceAll('#', '0xff')));
  }

  String _getTypeText() {
    switch (prediction.type) {
      case PredictionType.increase:
        return 'NAIK';
      case PredictionType.decrease:
        return 'TURUN';
      case PredictionType.critical:
        return 'KRITIS';
      case PredictionType.stable:
        return 'STABIL';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getReasonText(PredictionReason reason) {
    switch (reason) {
      case PredictionReason.weather:
        return 'Cuaca';
      case PredictionReason.holiday:
        return 'Libur';
      case PredictionReason.localEvent:
        return 'Event';
      case PredictionReason.trend:
        return 'Trend';
      case PredictionReason.stockIssue:
        return 'Stok';
      case PredictionReason.seasonality:
        return 'Musiman';
      case PredictionReason.historical:
        return 'Historis';
    }
  }
}
