import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sales_data.dart';
import '../models/menu_item.dart';
import '../models/prediction.dart';
import '../models/user.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hokben_prediction.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create menu_items table
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_path TEXT,
        ingredients TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create sales_data table
    await db.execute('''
      CREATE TABLE sales_data (
        id TEXT PRIMARY KEY,
        menu_item_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        date TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        day_of_month INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        temperature REAL,
        weather_condition TEXT,
        is_holiday INTEGER DEFAULT 0,
        is_local_event INTEGER DEFAULT 0,
        event_type TEXT,
        additional_metrics TEXT,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Create predictions table
    await db.execute('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY,
        menu_item_id TEXT NOT NULL,
        menu_item_name TEXT NOT NULL,
        type TEXT NOT NULL,
        predicted_quantity REAL NOT NULL,
        confidence_level REAL NOT NULL,
        percentage_change REAL NOT NULL,
        prediction_date TEXT NOT NULL,
        target_date TEXT NOT NULL,
        reasons TEXT NOT NULL,
        description TEXT NOT NULL,
        raw_ml_output TEXT,
        is_significant INTEGER DEFAULT 0,
        alert_level TEXT,
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        role TEXT NOT NULL,
        profile_image_path TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER DEFAULT 1,
        preferences TEXT
      )
    ''');

    // Create app_settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  Future<void> _insertSampleData(Database db) async {
    // Insert sample menu items
    final sampleMenuItems = [
      {
        'id': 'menu_1',
        'name': 'Bento Special 3',
        'category': 'Bento',
        'price': 45000.0,
        'description': 'Nasi dengan chicken teriyaki, beef yakiniku, dan gyoza',
        'image_path': '',
        'ingredients':
            '{"chicken": 150, "beef": 100, "rice": 200, "vegetables": 50}',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'menu_2',
        'name': 'Beef Teriyaki',
        'category': 'Rice Bowl',
        'price': 35000.0,
        'description': 'Nasi dengan beef teriyaki dan sayuran',
        'image_path': '',
        'ingredients': '{"beef": 180, "rice": 200, "teriyaki_sauce": 30}',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'menu_3',
        'name': 'Chicken Katsu',
        'category': 'Rice Bowl',
        'price': 32000.0,
        'description': 'Ayam katsu dengan nasi dan salad',
        'image_path': '',
        'ingredients': '{"chicken": 200, "rice": 200, "breadcrumbs": 50}',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'menu_4',
        'name': 'Salmon Teriyaki',
        'category': 'Rice Bowl',
        'price': 42000.0,
        'description': 'Nasi dengan salmon teriyaki',
        'image_path': '',
        'ingredients': '{"salmon": 180, "rice": 200, "teriyaki_sauce": 30}',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'menu_5',
        'name': 'Ebi Furai',
        'category': 'Bento',
        'price': 38000.0,
        'description': 'Udang goreng tepung dengan nasi',
        'image_path': '',
        'ingredients': '{"shrimp": 150, "rice": 200, "breadcrumbs": 50}',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in sampleMenuItems) {
      await db.insert('menu_items', item);
    }

    // Insert sample sales data
    await _insertSampleSalesData(db);

    // Insert sample predictions
    await _insertSamplePredictions(db);

    // Insert default settings
    await db.insert('app_settings', {
      'key': 'model_version',
      'value': '1.2.3',
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('app_settings', {
      'key': 'last_model_training',
      'value': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _insertSamplePredictions(Database db) async {
    final now = DateTime.now();
    final random = Random(42); // Fixed seed for consistency

    // Generate predictions for the next 7 days
    final predictions = [
      // Significant prediction - increase
      {
        'id': 'pred_1_${now.millisecondsSinceEpoch}',
        'menu_item_id': 'menu_1',
        'menu_item_name': 'Bento Special 3',
        'type': 'increase',
        'predicted_quantity': 72.0,
        'confidence_level': 0.94,
        'percentage_change': 20.0,
        'prediction_date': now.toIso8601String(),
        'target_date': now.add(const Duration(days: 1)).toIso8601String(),
        'reasons': '["localEvent", "trend"]',
        'description':
            'Diprediksi naik 20.0% pada besok karena faktor positif',
        'raw_ml_output': '{"predicted_quantity": 72.0, "confidence": 0.94}',
        'is_significant': 1,
        'alert_level': null,
      },
      // Significant prediction - decrease
      {
        'id': 'pred_2_${now.millisecondsSinceEpoch}',
        'menu_item_id': 'menu_2',
        'menu_item_name': 'Beef Teriyaki',
        'type': 'decrease',
        'predicted_quantity': 38.0,
        'confidence_level': 0.89,
        'percentage_change': -18.0,
        'prediction_date': now.toIso8601String(),
        'target_date': now.add(const Duration(days: 1)).toIso8601String(),
        'reasons': '["stockIssue", "weather"]',
        'description': 'Diprediksi turun 18.0% pada besok',
        'raw_ml_output': '{"predicted_quantity": 38.0, "confidence": 0.89}',
        'is_significant': 1,
        'alert_level': 'warning',
      },
      // Normal predictions
      {
        'id': 'pred_3_${now.millisecondsSinceEpoch}',
        'menu_item_id': 'menu_3',
        'menu_item_name': 'Chicken Katsu',
        'type': 'stable',
        'predicted_quantity': 47.0,
        'confidence_level': 0.91,
        'percentage_change': 4.4,
        'prediction_date': now.toIso8601String(),
        'target_date': now.add(const Duration(days: 1)).toIso8601String(),
        'reasons': '["historical"]',
        'description': 'Penjualan stabil dengan sedikit peningkatan',
        'raw_ml_output': '{"predicted_quantity": 47.0, "confidence": 0.91}',
        'is_significant': 0,
        'alert_level': null,
      },
      {
        'id': 'pred_4_${now.millisecondsSinceEpoch}',
        'menu_item_id': 'menu_4',
        'menu_item_name': 'Salmon Teriyaki',
        'type': 'stable',
        'predicted_quantity': 38.0,
        'confidence_level': 0.88,
        'percentage_change': 8.6,
        'prediction_date': now.toIso8601String(),
        'target_date': now.add(const Duration(days: 1)).toIso8601String(),
        'reasons': '["historical", "trend"]',
        'description': 'Penjualan stabil dengan sedikit peningkatan',
        'raw_ml_output': '{"predicted_quantity": 38.0, "confidence": 0.88}',
        'is_significant': 0,
        'alert_level': null,
      },
      {
        'id': 'pred_5_${now.millisecondsSinceEpoch}',
        'menu_item_id': 'menu_5',
        'menu_item_name': 'Ebi Furai',
        'type': 'stable',
        'predicted_quantity': 43.0,
        'confidence_level': 0.90,
        'percentage_change': 7.5,
        'prediction_date': now.toIso8601String(),
        'target_date': now.add(const Duration(days: 1)).toIso8601String(),
        'reasons': '["historical"]',
        'description': 'Penjualan stabil dengan sedikit peningkatan',
        'raw_ml_output': '{"predicted_quantity": 43.0, "confidence": 0.90}',
        'is_significant': 0,
        'alert_level': null,
      },
    ];

    for (final prediction in predictions) {
      await db.insert('predictions', prediction);
    }
  }

  Future<void> _insertSampleSalesData(Database db) async {
    final now = DateTime.now();
    final random = Random();

    // Price map for menu items
    const menuPrices = {
      1: 45000.0,
      2: 35000.0,
      3: 32000.0,
      4: 42000.0,
      5: 38000.0,
    };

    // Base quantities for menu items
    const baseQuantities = {
      1: 60,
      2: 50,
      3: 45,
      4: 35,
      5: 40,
    };

    // Generate sales data for the past 180 days (6 months)
    for (int i = 0; i < 180; i++) {
      final date = now.subtract(Duration(days: i));

      // Generate sales for each menu item
      for (int menuIdx = 1; menuIdx <= 5; menuIdx++) {
        // Base quantity varies by menu item
        final baseQuantity = baseQuantities[menuIdx]!;

        // Add variance and weekend boost
        final weekendBoost = date.weekday >= 6 ? 1.3 : 1.0;
        final variance = random.nextInt(20) - 10; // -10 to +10
        final quantity =
            ((baseQuantity + variance) * weekendBoost).round();

        final price = menuPrices[menuIdx]!;

        await db.insert('sales_data', {
          'id': 'sales_${menuIdx}_${date.millisecondsSinceEpoch}',
          'menu_item_id': 'menu_$menuIdx',
          'quantity': quantity,
          'total_amount': quantity * price,
          'date': date.toIso8601String(),
          'day_of_week': date.weekday,
          'day_of_month': date.day,
          'month': date.month,
          'year': date.year,
          'temperature': 25 + random.nextInt(10),
          'weather_condition': ['sunny', 'cloudy', 'rainy'][random.nextInt(3)],
          'is_holiday': date.weekday >= 6 ? 1 : 0,
          'is_local_event': random.nextBool() ? 1 : 0,
          'additional_metrics': '{}',
        });
      }
    }
  }

  // Menu Items operations
  Future<List<MenuItem>> getAllMenuItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');

    return List.generate(maps.length, (i) {
      return MenuItem.fromJson(maps[i]);
    });
  }

  Future<void> insertMenuItem(MenuItem item) async {
    final db = await database;
    await db.insert('menu_items', item.toJson());
  }

  // Sales Data operations
  Future<List<SalesData>> getSalesData({
    String? menuItemId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (menuItemId != null) {
      whereClause += 'menu_item_id = ?';
      whereArgs.add(menuItemId);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'sales_data',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return SalesData.fromJson(maps[i]);
    });
  }

  // Predictions operations
  Future<List<Prediction>> getPredictions({
    DateTime? targetDate,
    bool? significantOnly,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (targetDate != null) {
      whereClause = 'target_date = ?';
      whereArgs.add(targetDate.toIso8601String());
    }

    if (significantOnly == true) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'is_significant = 1';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'predictions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'prediction_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Prediction.fromJson(maps[i]);
    });
  }

  Future<void> insertPrediction(Prediction prediction) async {
    final db = await database;
    await db.insert(
      'predictions',
      prediction.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPredictions(List<Prediction> predictions) async {
    final db = await database;
    final batch = db.batch();

    for (final prediction in predictions) {
      batch.insert(
        'predictions',
        prediction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  // Settings operations
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Clear all predictions (for retraining)
  Future<void> clearPredictions() async {
    final db = await database;
    await db.delete('predictions');
  }

  // Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final menuItemCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM menu_items'),
        ) ??
        0;

    final salesDataCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM sales_data'),
        ) ??
        0;

    final predictionCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM predictions'),
        ) ??
        0;

    return {
      'menu_items': menuItemCount,
      'sales_data': salesDataCount,
      'predictions': predictionCount,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
