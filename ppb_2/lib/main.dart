// import 'package:flutter/material.dart';
// import 'dbhelper.dart';
// import 'notemodel.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SQFlite CRUD',
//       home: NotePage(),
//     );
//   }
// }
//
// class NotePage extends StatefulWidget {
//   @override
//   State<NotePage> createState() => _NotePageState();
// }
//
// class _NotePageState extends State<NotePage> {
//   final DBHelper dbHelper = DBHelper();
//   final titleController = TextEditingController();
//   final contentController = TextEditingController();
//
//   List<Note> notes = [];
//   Note? editingNote;
//
//   @override
//   void initState() {
//     super.initState();
//     refreshNotes();
//   }
//
//   Future<void> refreshNotes() async {
//     notes = await dbHelper.getNotes();
//     setState(() {});
//   }
//
//   void clearForm() {
//     titleController.clear();
//     contentController.clear();
//     editingNote = null;
//   }
//
//   Future<void> saveNote() async {
//     final title = titleController.text;
//     final content = contentController.text;
//
//     if (editingNote == null) {
//       await dbHelper.insertNote(Note(title: title, content: content));
//     } else {
//       await dbHelper.updateNote(Note(
//         id: editingNote!.id,
//         title: title,
//         content: content,
//       ));
//     }
//
//     clearForm();
//     refreshNotes();
//   }
//
//   Future<void> deleteNote(int id) async {
//     await dbHelper.deleteNote(id);
//     refreshNotes();
//   }
//
//   void editNote(Note note) {
//     titleController.text = note.title;
//     contentController.text = note.content;
//     editingNote = note;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('SQFlite CRUD')),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(labelText: 'Judul'),
//             ),
//             TextField(
//               controller: contentController,
//               decoration: InputDecoration(labelText: 'Isi'),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: saveNote,
//               child: Text(editingNote == null ? 'Simpan' : 'Update'),
//             ),
//             Divider(),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: notes.length,
//                 itemBuilder: (context, index) {
//                   final note = notes[index];
//                   return ListTile(
//                     title: Text(note.title),
//                     subtitle: Text(note.content),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(icon: Icon(Icons.edit), onPressed: () => editNote(note)),
//                         IconButton(icon: Icon(Icons.delete), onPressed: () => deleteNote(note.id!)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'journalmodel.dart';
import 'dbhelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JournalDatabase.instance.database;
  await _insertDummyData();
  runApp(const MyApp());
}

Future<void> _insertDummyData() async {
  final db = JournalDatabase.instance;
  final existing = await db.getAllJournals();
  print('existing journals: ${existing.length}');

  if (existing.isEmpty) {
    print('Inserting dummy data...');
    await db.insertJournal(Journal(title: 'My First Journal', content: 'This is my first journal entry.'));
    await db.insertJournal(Journal(title: 'Flutter Journey', content: 'Learning Flutter is fun and exciting!'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journaling App',
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: const JournalsScreen(),
    );
  }
}

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  _JournalsScreenState createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  List<Journal> _journals = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final data = await JournalDatabase.instance.getAllJournals();
    setState(() {
      _journals = data;
    });
  }

  Future<void> _addJournal() async {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final newJournal = Journal(title: _titleController.text, content: _contentController.text);
      await JournalDatabase.instance.insertJournal(newJournal);
      _titleController.clear();
      _contentController.clear();
      _loadJournals();
    }
  }

  void _editJournal(int index, String newTitle, String newContent) async {
    final edited = _journals[index];
    final updated = Journal(id: edited.id, title: newTitle, content: newContent);
    await JournalDatabase.instance.updateJournal(updated);
    _loadJournals();
  }

  void _deleteJournal(int index) async {
    await JournalDatabase.instance.deleteJournal(_journals[index].id!);
    _loadJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Journals',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Text(
                  'Welcome back! Nice to see you. What is your story today?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Text(
                    'Add New Journal',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You have ${_journals.length} journal${_journals.length == 1 ? "" : "s"}',
                style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) {
                return JournalItem(
                  journal: _journals[index],
                  onEdit: (newTitle, newContent) => _editJournal(index, newTitle, newContent),
                  onDelete: () => _deleteJournal(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JournalItem extends StatelessWidget {
  final Journal journal;
  final Function(String, String) onEdit;
  final VoidCallback onDelete;

  const JournalItem({
    super.key,
    required this.journal,
    required this.onEdit,
    required this.onDelete,
  });

  void _showEditDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController(text: journal.title);
    final TextEditingController contentController = TextEditingController(text: journal.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Journal',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onEdit(titleController.text, contentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(journal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(journal.content),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}