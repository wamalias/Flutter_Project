// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'notemodel.dart';
//
// class DBHelper {
//   static final DBHelper _instance = DBHelper._();
//   static Database? _database;
//
//   DBHelper._();
//
//   factory DBHelper() => _instance;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('notes.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String fileName) async {
//     final path = join(await getDatabasesPath(), fileName);
//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }
//
//   Future<void> _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE notes (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         title TEXT,
//         content TEXT
//       )
//     ''');
//   }
//
//   Future<int> insertNote(Note note) async {
//     final db = await database;
//     return await db.insert('notes', note.toMap());
//   }
//
//   Future<List<Note>> getNotes() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('notes');
//     return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
//   }
//
//   Future<int> updateNote(Note note) async {
//     final db = await database;
//     return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
//   }
//
//   Future<int> deleteNote(int id) async {
//     final db = await database;
//     return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'journalmodel.dart';

class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();
  static Database? _database;

  JournalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  Future<Journal> insertJournal(Journal journal) async {
    final db = await instance.database;
    final id = await db.insert('journals', journal.toMap());
    return journal.copyWith(id: id);
  }

  Future<List<Journal>> getAllJournals() async {
    final db = await instance.database;
    final result = await db.query('journals');
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  Future<int> updateJournal(Journal journal) async {
    final db = await instance.database;
    return await db.update(
      'journals',
      journal.toMap(),
      where: 'id = ?',
      whereArgs: [journal.id],
    );
  }

  Future<int> deleteJournal(int id) async {
    final db = await instance.database;
    return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
