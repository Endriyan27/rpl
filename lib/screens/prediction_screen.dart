import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/prediction_card.dart';
import '../widgets/significant_prediction_card.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().loadPredictions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prediksi Menu Harian',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PredictionProvider>().refreshPredictions();
            },
          ),
        ],
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, predictionProvider, child) {
          if (predictionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (predictionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    predictionProvider.error!,
                    style: TextStyle(fontSize: 16, color: Colors.red[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      predictionProvider.loadPredictions();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => predictionProvider.refreshPredictions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Significant Predictions Section
                  if (predictionProvider.significantPredictions.isNotEmpty) ...[
                    const Text(
                      'Prediksi Signifikan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...predictionProvider.significantPredictions.map(
                      (prediction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SignificantPredictionCard(
                          prediction: prediction,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // All Predictions Section
                  const Text(
                    'Semua Prediksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ...predictionProvider.predictions.map(
                    (prediction) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PredictionCard(
                        prediction: prediction,
                        onTap: () {
                          // Navigate to prediction detail
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<PredictionProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: provider.isTrainingModel
                ? null
                : () => provider.trainModel(),
            icon: provider.isTrainingModel
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.model_training),
            label: Text(
              provider.isTrainingModel ? 'Training...' : 'Latih Ulang Model',
            ),
          );
        },
      ),
    );
  }
}
