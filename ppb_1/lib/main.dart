import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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

class Journal {
  String title;
  String content;

  Journal(this.title, this.content);
}

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  _JournalsScreenState createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  final List<Journal> _journals = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _addJournal() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      setState(() {
        _journals.add(Journal(_titleController.text, _contentController.text));
      });
      _titleController.clear();
      _contentController.clear();
    }
  }

  void _editJournal(int index, String newTitle, String newContent) {
    setState(() {
      _journals[index].title = newTitle;
      _journals[index].content = newContent;
    });
  }

  void _deleteJournal(int index) {
    setState(() {
      _journals.removeAt(index);
    });
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