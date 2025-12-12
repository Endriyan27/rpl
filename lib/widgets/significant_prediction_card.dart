import 'package:flutter/material.dart';
import '../models/prediction.dart';

class SignificantPredictionCard extends StatelessWidget {
  final Prediction prediction;

  const SignificantPredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_getGradientColor().withOpacity(0.8), _getGradientColor()],
        ),
        boxShadow: [
          BoxShadow(
            color: _getGradientColor().withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getIcon(), color: Colors.white, size: 24),
                ),
                const Spacer(),
                if (prediction.alertLevel == 'critical')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.red[600]),
                        const SizedBox(width: 4),
                        Text(
                          'ALERT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              prediction.menuItemName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              prediction.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perubahan Diprediksi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        prediction.displayPercentage,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Target',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        _formatDate(prediction.targetDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradientColor() {
    switch (prediction.type) {
      case PredictionType.increase:
        return Colors.green[600]!;
      case PredictionType.decrease:
        return Colors.orange[600]!;
      case PredictionType.critical:
        return Colors.red[600]!;
      case PredictionType.stable:
        return Colors.blue[600]!;
    }
  }

  IconData _getIcon() {
    switch (prediction.type) {
      case PredictionType.increase:
        return Icons.trending_up;
      case PredictionType.decrease:
        return Icons.trending_down;
      case PredictionType.critical:
        return Icons.warning;
      case PredictionType.stable:
        return Icons.trending_flat;
    }
  }

  String _getTitle() {
    switch (prediction.type) {
      case PredictionType.increase:
        return 'Lonjakan: ${prediction.menuItemName}';
      case PredictionType.decrease:
        return 'Penurunan: ${prediction.menuItemName}';
      case PredictionType.critical:
        return 'Peringatan Stok: ${prediction.menuItemName}';
      case PredictionType.stable:
        return 'Stabil: ${prediction.menuItemName}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference == 2) {
      return 'Lusa';
    } else {
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
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}
