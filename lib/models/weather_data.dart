class WeatherData {
  final String id;
  final DateTime date;
  final double temperature;
  final double humidity;
  final String condition; // sunny, cloudy, rainy, stormy
  final double windSpeed;
  final double precipitation;
  final String description;

  WeatherData({
    required this.id,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.windSpeed,
    required this.precipitation,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'temperature': temperature,
    'humidity': humidity,
    'condition': condition,
    'windSpeed': windSpeed,
    'precipitation': precipitation,
    'description': description,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    id: json['id'],
    date: DateTime.parse(json['date']),
    temperature: json['temperature']?.toDouble() ?? 25.0,
    humidity: json['humidity']?.toDouble() ?? 60.0,
    condition: json['condition'] ?? 'sunny',
    windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
    precipitation: json['precipitation']?.toDouble() ?? 0.0,
    description: json['description'] ?? '',
  );

  String get temperatureText => '${temperature.toInt()}°C';

  String get conditionText {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'Cerah';
      case 'cloudy':
        return 'Berawan';
      case 'rainy':
        return 'Hujan';
      case 'stormy':
        return 'Badai';
      default:
        return condition;
    }
  }

  String get iconPath {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'assets/weather/sunny.png';
      case 'cloudy':
        return 'assets/weather/cloudy.png';
      case 'rainy':
        return 'assets/weather/rainy.png';
      case 'stormy':
        return 'assets/weather/stormy.png';
      default:
        return 'assets/weather/default.png';
    }
  }
}

class StockData {
  final String id;
  final String ingredientName;
  final double currentStock;
  final double minimumStock;
  final String unit;
  final DateTime lastUpdated;
  final double? pricePerUnit;
  final String? supplier;

  StockData({
    required this.id,
    required this.ingredientName,
    required this.currentStock,
    required this.minimumStock,
    required this.unit,
    required this.lastUpdated,
    this.pricePerUnit,
    this.supplier,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ingredientName': ingredientName,
    'currentStock': currentStock,
    'minimumStock': minimumStock,
    'unit': unit,
    'lastUpdated': lastUpdated.toIso8601String(),
    'pricePerUnit': pricePerUnit,
    'supplier': supplier,
  };

  factory StockData.fromJson(Map<String, dynamic> json) => StockData(
    id: json['id'],
    ingredientName: json['ingredientName'],
    currentStock: json['currentStock']?.toDouble() ?? 0.0,
    minimumStock: json['minimumStock']?.toDouble() ?? 0.0,
    unit: json['unit'] ?? 'kg',
    lastUpdated: DateTime.parse(json['lastUpdated']),
    pricePerUnit: json['pricePerUnit']?.toDouble(),
    supplier: json['supplier'],
  );

  bool get isLowStock => currentStock <= minimumStock;
  bool get isCriticalStock => currentStock <= (minimumStock * 0.5);

  double get stockPercentage {
    if (minimumStock == 0) return 100.0;
    return (currentStock / minimumStock) * 100.0;
  }

  String get statusText {
    if (isCriticalStock) return 'Kritis';
    if (isLowStock) return 'Rendah';
    return 'Normal';
  }

  String get statusColor {
    if (isCriticalStock) return '#F44336'; // Red
    if (isLowStock) return '#FF9800'; // Orange
    return '#4CAF50'; // Green
  }
}
