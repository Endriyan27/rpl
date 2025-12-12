import 'package:flutter/material.dart';
import '../models/ml_model_info.dart';

class ModelStatusCard extends StatelessWidget {
  final MLModelInfo modelInfo;
  final VoidCallback? onTrainModel;

  const ModelStatusCard({
    super.key,
    required this.modelInfo,
    this.onTrainModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Sistem Cerdas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Model Status Indicator
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Model ANN: ${modelInfo.statusText}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showModelDetails(context);
                  },
                  child: const Text('Latih Ulang'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Model Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'TERAKHIR DILATIH',
                    modelInfo.lastTrainingText,
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'AKURASI (ERROR)',
                    '${(modelInfo.accuracy * 100).toInt()}% (${(modelInfo.errorRate * 100).toStringAsFixed(1)}%)',
                    Icons.analytics,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quality Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Model saat ini menggunakan 12 fitur input termasuk cuaca dan hari libur. Performa stabil.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    return Color(int.parse(modelInfo.statusColor.replaceAll('#', '0xff')));
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showModelDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Detail Model ANN',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Model Info
              _buildDetailRow('Status', modelInfo.statusText),
              _buildDetailRow('Versi', modelInfo.version),
              _buildDetailRow(
                'Akurasi',
                '${(modelInfo.accuracy * 100).toInt()}%',
              ),
              _buildDetailRow(
                'Error Rate',
                '${(modelInfo.errorRate * 100).toStringAsFixed(2)}%',
              ),
              _buildDetailRow(
                'Total Prediksi',
                modelInfo.totalPredictions.toString(),
              ),
              _buildDetailRow(
                'Prediksi Benar',
                modelInfo.correctPredictions.toString(),
              ),
              _buildDetailRow('Kualitas', modelInfo.qualityIndicator),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onTrainModel?.call();
                      },
                      child: const Text('Latih Ulang'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
