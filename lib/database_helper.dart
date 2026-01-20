import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stoic_vigilance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day INTEGER,
        task TEXT,
        report TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<int> insertLog(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('logs', row);
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    Database db = await database;
    return await db.query('logs', orderBy: 'day DESC');
  }
}
