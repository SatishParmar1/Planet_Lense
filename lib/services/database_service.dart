import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/plant_history.dart';

class DatabaseService {
  static const String _databaseName = 'plant_finder.db';
  static const int _databaseVersion = 1;
  
  static const String tableHistory = 'plant_history';
  
  static Database? _database;
  
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);
      
      if (kDebugMode) {
        print('Database path: $path');
      }
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing database: $error');
      }
      rethrow;
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $tableHistory(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          imagePath TEXT NOT NULL,
          plantName TEXT NOT NULL,
          scientificName TEXT NOT NULL,
          description TEXT NOT NULL,
          confidence REAL NOT NULL,
          isFavorite INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          additionalData TEXT
        )
      ''');
      
      // Create index for better performance
      await db.execute('''
        CREATE INDEX idx_user_created ON $tableHistory(userId, createdAt DESC)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_favorites ON $tableHistory(userId, isFavorite, createdAt DESC)
      ''');
      
      if (kDebugMode) {
        print('Database tables created successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating database tables: $error');
      }
      rethrow;
    }
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (kDebugMode) {
      print('Database upgraded from version $oldVersion to $newVersion');
    }
  }
  
  // Insert new plant history record
  Future<int> insertPlantHistory(PlantHistory history) async {
    try {
      final db = await database;
      final id = await db.insert(tableHistory, history.toMap());
      
      if (kDebugMode) {
        print('Inserted plant history with id: $id');
      }
      
      return id;
    } catch (error) {
      if (kDebugMode) {
        print('Error inserting plant history: $error');
      }
      rethrow;
    }
  }
  
  // Get all plant history for a user
  Future<List<PlantHistory>> getPlantHistory(String userId, {int? limit}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableHistory,
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
        limit: limit,
      );
      
      return List.generate(maps.length, (i) {
        return PlantHistory.fromMap(maps[i]);
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error getting plant history: $error');
      }
      return [];
    }
  }
  
  // Get favorite plants for a user
  Future<List<PlantHistory>> getFavoritePlants(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableHistory,
        where: 'userId = ? AND isFavorite = ?',
        whereArgs: [userId, 1],
        orderBy: 'createdAt DESC',
      );
      
      return List.generate(maps.length, (i) {
        return PlantHistory.fromMap(maps[i]);
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error getting favorite plants: $error');
      }
      return [];
    }
  }
  
  // Update favorite status
  Future<void> updateFavoriteStatus(int id, bool isFavorite) async {
    try {
      final db = await database;
      await db.update(
        tableHistory,
        {'isFavorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (kDebugMode) {
        print('Updated favorite status for id: $id to $isFavorite');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating favorite status: $error');
      }
      rethrow;
    }
  }
  
  // Delete plant history record
  Future<void> deletePlantHistory(int id) async {
    try {
      final db = await database;
      await db.delete(
        tableHistory,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (kDebugMode) {
        print('Deleted plant history with id: $id');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting plant history: $error');
      }
      rethrow;
    }
  }
  
  // Search plant history
  Future<List<PlantHistory>> searchPlantHistory(String userId, String searchTerm) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableHistory,
        where: '''userId = ? AND (
          plantName LIKE ? OR 
          scientificName LIKE ? OR 
          description LIKE ?
        )''',
        whereArgs: [
          userId,
          '%$searchTerm%',
          '%$searchTerm%',
          '%$searchTerm%',
        ],
        orderBy: 'createdAt DESC',
      );
      
      return List.generate(maps.length, (i) {
        return PlantHistory.fromMap(maps[i]);
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error searching plant history: $error');
      }
      return [];
    }
  }
  
  // Get statistics for a user
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final db = await database;
      
      // Total plants identified
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableHistory WHERE userId = ?',
        [userId],
      );
      int totalPlants = totalResult.first['count'] as int;
      
      // Total favorites
      final favoritesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableHistory WHERE userId = ? AND isFavorite = 1',
        [userId],
      );
      int totalFavorites = favoritesResult.first['count'] as int;
      
      // Recent scans (last 7 days)
      final DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableHistory WHERE userId = ? AND createdAt >= ?',
        [userId, weekAgo.toIso8601String()],
      );
      int recentScans = recentResult.first['count'] as int;
      
      // Calculate streak days (consecutive days with at least one scan)
      int streakDays = await _calculateStreakDays(userId);
      
      return {
        'totalPlants': totalPlants,
        'totalFavorites': totalFavorites,
        'recentScans': recentScans,
        'streakDays': streakDays,
      };
    } catch (error) {
      if (kDebugMode) {
        print('Error getting user stats: $error');
      }
      return {
        'totalPlants': 0,
        'totalFavorites': 0,
        'recentScans': 0,
        'streakDays': 0,
      };
    }
  }
  
  Future<int> _calculateStreakDays(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT DATE(createdAt) as date 
        FROM $tableHistory 
        WHERE userId = ? 
        ORDER BY date DESC
      ''', [userId]);
      
      if (maps.isEmpty) return 0;
      
      int streakDays = 0;
      DateTime currentDate = DateTime.now();
      
      for (var map in maps) {
        DateTime recordDate = DateTime.parse(map['date']);
        DateTime expectedDate = currentDate.subtract(Duration(days: streakDays));
        
        // Check if the record date matches the expected date (within the same day)
        if (recordDate.year == expectedDate.year &&
            recordDate.month == expectedDate.month &&
            recordDate.day == expectedDate.day) {
          streakDays++;
        } else {
          break;
        }
      }
      
      return streakDays;
    } catch (error) {
      if (kDebugMode) {
        print('Error calculating streak days: $error');
      }
      return 0;
    }
  }
  
  // Clear all data for a user (when they sign out)
  Future<void> clearUserData(String userId) async {
    try {
      final db = await database;
      await db.delete(
        tableHistory,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      if (kDebugMode) {
        print('Cleared all data for user: $userId');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error clearing user data: $error');
      }
      rethrow;
    }
  }
  
  // Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
