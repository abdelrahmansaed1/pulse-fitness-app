import 'package:pulse_fitness_app/core/theme/app_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatasource {
  LocalDatasource._();
  static final LocalDatasource instance = LocalDatasource._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
 CREATE TABLE workouts (
        id               TEXT PRIMARY KEY,
        activity_type    TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        calories         REAL NOT NULL,
        steps            INTEGER NOT NULL DEFAULT 0,
        notes            TEXT NOT NULL DEFAULT '',
        date             TEXT NOT NULL
      )
 ''');
    await db.execute('''
      CREATE TABLE daily_steps (
        date  TEXT PRIMARY KEY,
        steps INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE water_log (
        date      TEXT PRIMARY KEY,
        amount_ml INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ── Workout queries ───────────────────────────────────────────────────────
  Future<void> insertWorkout(Map<String, dynamic> map) async {
    final db = await _database;
    await db.insert(
      'workouts',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWorkout(String id) async {
    final db = await _database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllWorkouts() async {
    final db = await _database;
    return db.query('workouts', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> queryWorkoutsByDateRange(
    String start,
    String end,
  ) async {
    final db = await _database;
    return db.query(
      'workouts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
  }
  // ── Steps queries ─────────────────────────────────────────────────────────

  Future<void> upsertSteps(String dateKey, int steps) async {
    final db = await _database;
    await db.insert('daily_steps', {
      'date': dateKey,
      'steps': steps,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> querySteps(String dateKey) async {
    final db = await _database;
    final rows = await db.query(
      'daily_steps',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> queryStepsRange(
    List<String> dateKeys,
  ) async {
    final db = await _database;
    final placeholders = dateKeys.map((_) => '?').join(', ');
    return db.rawQuery(
      'SELECT * FROM daily_steps WHERE date IN ($placeholders)',
      dateKeys,
    );
  }

  // ── Water queries ─────────────────────────────────────────────────────────
  Future<void> upsertWater(String dateKey, int amountMl) async {
    final db = await _database;
    await db.insert('water_log', {
      'date': dateKey,
      'amount_ml': amountMl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> queryWater(String dateKey) async {
    final db = await _database;
    final rows = await db.query(
      'water_log',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    return rows.isEmpty ? null : rows.first;
  }

  // ── Clear all data ────────────────────────────────────────────────────────
  Future<void> clearAllData() async {
    final db = await _database;
    await db.delete('workouts');
    await db.delete('daily_steps');
    await db.delete('water_log');
  }
}
