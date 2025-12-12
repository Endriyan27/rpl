class MenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imagePath;
  final Map<String, double> ingredients; // ingredient name -> quantity needed
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.imagePath = '',
    this.ingredients = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'description': description,
    'imagePath': imagePath,
    'ingredients': ingredients,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    price: json['price']?.toDouble() ?? 0.0,
    description: json['description'] ?? '',
    imagePath: json['imagePath'] ?? '',
    ingredients: Map<String, double>.from(json['ingredients'] ?? {}),
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imagePath,
    Map<String, double>? ingredients,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      ingredients: ingredients ?? this.ingredients,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
