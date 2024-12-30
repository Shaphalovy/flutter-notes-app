import 'package:flutter/material.dart';
import 'database/local/db_helper.dart';
import 'package:intl/intl.dart'; // For formatting dates

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DBHelper dbHelper = DBHelper(); // Database instance
  List<Map<String, dynamic>> notes = []; // List to store notes

  @override
  void initState() {
    super.initState();
    loadNotes(); // Load notes when the app starts
  }

  void loadNotes() async {
    final data = await dbHelper.fetchNotes();
    setState(() {
      notes = data;
    });
  }

  void deleteNotes(int id) async {
    await dbHelper.deleteNote(id); // Delete from database
    loadNotes(); // Refresh the notes list
  }

  void showNoteBottomSheet({Map<String, dynamic>? note}) {
    final TextEditingController titleController =
    TextEditingController(text: note?['title'] ?? '');
    final TextEditingController contentController =
    TextEditingController(text: note?['content'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                note == null ? 'Add Note' : 'Edit Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      contentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  final newNote = {
                    'title': titleController.text,
                    'content': contentController.text,
                    'date': DateTime.now().toString(),
                  };

                  if (note == null) {
                    // Add new note
                    await dbHelper.insertNote(newNote);
                  } else {
                    // Update existing note
                    await dbHelper.updateNote(note['id'], newNote);
                  }

                  loadNotes(); // Refresh the notes list
                  Navigator.pop(context); // Close the BottomSheet
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(note == null ? 'Add Note' : 'Update Note'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: notes.isEmpty
          ? Center(
        child: Text(
          'No Notes Yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
              .format(DateTime.parse(note['date']));

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Text(
                note['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    note['content'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showNoteBottomSheet(note: note),
                    icon: Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => deleteNotes(note['id']),
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteBottomSheet(),
        child: Icon(Icons.add),
        tooltip: 'Add a new note',
      ),
    );
  }
}
