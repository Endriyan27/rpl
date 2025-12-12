class SalesData {
  final String id;
  final String menuItemId;
  final int quantity;
  final double totalAmount;
  final DateTime date;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final int dayOfMonth;
  final int month;
  final int year;
  final double? temperature;
  final String? weatherCondition;
  final bool isHoliday;
  final bool isLocalEvent;
  final String? eventType;
  final Map<String, dynamic> additionalMetrics;

  SalesData({
    required this.id,
    required this.menuItemId,
    required this.quantity,
    required this.totalAmount,
    required this.date,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.month,
    required this.year,
    this.temperature,
    this.weatherCondition,
    this.isHoliday = false,
    this.isLocalEvent = false,
    this.eventType,
    this.additionalMetrics = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuItemId': menuItemId,
    'quantity': quantity,
    'totalAmount': totalAmount,
    'date': date.toIso8601String(),
    'dayOfWeek': dayOfWeek,
    'dayOfMonth': dayOfMonth,
    'month': month,
    'year': year,
    'temperature': temperature,
    'weatherCondition': weatherCondition,
    'isHoliday': isHoliday,
    'isLocalEvent': isLocalEvent,
    'eventType': eventType,
    'additionalMetrics': additionalMetrics,
  };

  factory SalesData.fromJson(Map<String, dynamic> json) => SalesData(
    id: json['id'],
    menuItemId: json['menuItemId'],
    quantity: json['quantity'],
    totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
    date: DateTime.parse(json['date']),
    dayOfWeek: json['dayOfWeek'],
    dayOfMonth: json['dayOfMonth'],
    month: json['month'],
    year: json['year'],
    temperature: json['temperature']?.toDouble(),
    weatherCondition: json['weatherCondition'],
    isHoliday: json['isHoliday'] ?? false,
    isLocalEvent: json['isLocalEvent'] ?? false,
    eventType: json['eventType'],
    additionalMetrics: Map<String, dynamic>.from(
      json['additionalMetrics'] ?? {},
    ),
  );

  // Convert to ML input features (12 features total)
  List<double> toMLFeatures() {
    return [
      dayOfWeek.toDouble(),
      dayOfMonth.toDouble(),
      month.toDouble(),
      year.toDouble(),
      temperature ?? 25.0, // default temperature
      isHoliday ? 1.0 : 0.0,
      isLocalEvent ? 1.0 : 0.0,
      quantity.toDouble(),
      totalAmount,
      _getWeatherNumeric(),
      _getSeasonality(),
      _getTrendFactor(),
    ];
  }

  double _getWeatherNumeric() {
    switch (weatherCondition?.toLowerCase()) {
      case 'sunny':
        return 1.0;
      case 'cloudy':
        return 0.5;
      case 'rainy':
        return 0.0;
      default:
        return 0.5;
    }
  }

  double _getSeasonality() {
    // Simple seasonality based on month
    if (month >= 6 && month <= 8) return 1.0; // Mid year
    if (month >= 12 || month <= 2) return 0.8; // End/Start of year
    return 0.6; // Other months
  }

  double _getTrendFactor() {
    // Historical trend factor (can be calculated based on historical data)
    return 1.0; // Default neutral trend
  }
}
