import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user.dart';

class MonthlySalesChart extends StatelessWidget {
  final List<MonthlySales> salesData;

  const MonthlySalesChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(child: Text('Tidak ada data penjualan'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final monthName = salesData[groupIndex].monthName;
              final value = _formatValue(rod.toY);
              return BarTooltipItem(
                '$monthName\n$value',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _buildBottomTitles,
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: _getMaxY() / 4,
              getTitlesWidget: _buildLeftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY() / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300], strokeWidth: 1);
          },
        ),
      ),
    );
  }

  double _getMaxY() {
    if (salesData.isEmpty) return 100;
    final maxSales = salesData
        .map((data) => data.totalSales)
        .reduce((a, b) => a > b ? a : b);
    return (maxSales * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _buildBarGroups() {
    return salesData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.totalSales,
            color: _getBarColor(index),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _getBarColor(index),
                _getBarColor(index).withOpacity(0.7),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= salesData.length) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        salesData[index].monthName,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    return Text(
      _formatValue(value),
      style: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
