import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  // Font size constant for value display
  static const double _valueFontSize = 20.0;

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;
  final String? growth;
  final Color? growthColor;
  final double? trend; // Trend percentage parameter

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.growth,
    this.growthColor,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate growth display from trend if provided
    String? displayGrowth = growth;
    Color? displayGrowthColor = growthColor;

    if (trend != null) {
      final sign = trend! >= 0 ? '+' : '';
      displayGrowth = '$sign${trend!.toStringAsFixed(1)}%';
      displayGrowthColor = trend! >= 0 ? const Color(0xFF00D05E) : Colors.red;
    }

    return Card(
      elevation: 2,
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
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Spacer(),
                if (displayGrowth != null && displayGrowthColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: displayGrowthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayGrowth,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: displayGrowthColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: _valueFontSize, // Use constant for maintainability
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
