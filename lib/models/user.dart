import 'ml_model_info.dart';

enum UserRole { admin, manager, staff }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImagePath,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.preferences = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'profileImagePath': profileImagePath,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'isActive': isActive,
    'preferences': preferences,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: UserRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => UserRole.staff,
    ),
    profileImagePath: json['profileImagePath'],
    createdAt: DateTime.parse(json['createdAt']),
    lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'])
        : null,
    isActive: json['isActive'] ?? true,
    preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
  );

  String get roleText {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  bool get canAccessSettings =>
      role == UserRole.admin || role == UserRole.manager;
  bool get canEditPredictions =>
      role == UserRole.admin || role == UserRole.manager;
  bool get canTrainModel => role == UserRole.admin;
  bool get canViewReports => true; // All roles can view reports

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}

class DashboardMetrics {
  final double totalSalesYTD;
  final double salesGrowthPercentage;
  final double averageOrdersPerDay;
  final double ordersGrowthPercentage;
  final List<MonthlySales> monthlySales;
  final MLModelInfo modelInfo;
  final DateTime lastUpdated;

  DashboardMetrics({
    required this.totalSalesYTD,
    required this.salesGrowthPercentage,
    required this.averageOrdersPerDay,
    required this.ordersGrowthPercentage,
    required this.monthlySales,
    required this.modelInfo,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'totalSalesYTD': totalSalesYTD,
    'salesGrowthPercentage': salesGrowthPercentage,
    'averageOrdersPerDay': averageOrdersPerDay,
    'ordersGrowthPercentage': ordersGrowthPercentage,
    'monthlySales': monthlySales.map((m) => m.toJson()).toList(),
    'modelInfo': modelInfo.toJson(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      DashboardMetrics(
        totalSalesYTD: json['totalSalesYTD']?.toDouble() ?? 0.0,
        salesGrowthPercentage: json['salesGrowthPercentage']?.toDouble() ?? 0.0,
        averageOrdersPerDay: json['averageOrdersPerDay']?.toDouble() ?? 0.0,
        ordersGrowthPercentage:
            json['ordersGrowthPercentage']?.toDouble() ?? 0.0,
        monthlySales:
            (json['monthlySales'] as List?)
                ?.map((m) => MonthlySales.fromJson(m))
                .toList() ??
            [],
        modelInfo: MLModelInfo.fromJson(json['modelInfo']),
        lastUpdated: DateTime.parse(json['lastUpdated']),
      );

  String get totalSalesText {
    if (totalSalesYTD >= 1000000) {
      return 'Rp ${(totalSalesYTD / 1000000).toStringAsFixed(1)}M';
    } else if (totalSalesYTD >= 1000) {
      return 'Rp ${(totalSalesYTD / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${totalSalesYTD.toStringAsFixed(0)}';
  }

  String get salesGrowthText {
    final sign = salesGrowthPercentage >= 0 ? '+' : '';
    return '$sign${salesGrowthPercentage.toStringAsFixed(1)}%';
  }

  String get ordersGrowthText {
    final sign = ordersGrowthPercentage >= 0 ? '+' : '';
    return '$sign${ordersGrowthPercentage.toStringAsFixed(1)}%';
  }
}

class MonthlySales {
  final int month;
  final int year;
  final double totalSales;
  final int totalOrders;
  final String monthName;

  MonthlySales({
    required this.month,
    required this.year,
    required this.totalSales,
    required this.totalOrders,
    required this.monthName,
  });

  Map<String, dynamic> toJson() => {
    'month': month,
    'year': year,
    'totalSales': totalSales,
    'totalOrders': totalOrders,
    'monthName': monthName,
  };

  factory MonthlySales.fromJson(Map<String, dynamic> json) => MonthlySales(
    month: json['month'],
    year: json['year'],
    totalSales: json['totalSales']?.toDouble() ?? 0.0,
    totalOrders: json['totalOrders'] ?? 0,
    monthName: json['monthName'],
  );
}
