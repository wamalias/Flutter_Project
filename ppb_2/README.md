# Make Database Structure
Terdiri dari 3 atribut yaitu id (int), title (string), dan content (string)
```
class Journal {
  final int? id;
  final String title;
  final String content;

  Journal({this.id, required this.title, required this.content});
}
```
# Database Helper
initialize database
```
Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(path, version: 1, onCreate: _createDB);
}
```
Get database
```
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDB('journals.db');
  return _database!;
}
```
Create database
```
Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE journals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL
    )
  ''');
}
```
insert new journal
```
Future<Journal> insertJournal(Journal journal) async {
  final db = await instance.database;
  final id = await db.insert('journals', journal.toMap());
  return journal.copyWith(id: id);
}
```
Get all journal
```
Future<List<Journal>> getAllJournals() async {
   final db = await instance.database;
   final result = await db.query('journals');
   return result.map((map) => Journal.fromMap(map)).toList();
}
```
Update journal
```
Future<int> updateJournal(Journal journal) async {
  final db = await instance.database;
  return await db.update(
    'journals',
    journal.toMap(),
    where: 'id = ?',
    whereArgs: [journal.id],
  );
}
```
Delete journal
```
Future<int> deleteJournal(int id) async {
  final db = await instance.database;
  return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
}
```
Close database
```
Future close() async {
  final db = await instance.database;
  db.close();
}
```
