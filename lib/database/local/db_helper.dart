import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DBHelper {

  //Making the class a singleton
  //
  //
  //static:
  //The variable _instance is declared as static, meaning it belongs to the class itself and is shared across all objects of this class.
  // Without static, every time we created an object of DBHelper, a new copy of _instance would exist, defeating the purpose of a singleton.
  // final:
  // The variable _instance is also final, meaning it can be set only once and cannot be reassigned.
  // DBHelper._internal():
  // This calls a special private constructor (explained in Step 3) to initialize the _instance.
  //
  //What is a factory constructor?
  // A factory constructor is a special constructor in Dart that does not always create a new instance of a class.
  // Instead, it can return an existing instance (in this case, _instance).
  //
  // Why use a factory constructor?
  // It ensures that whenever you write DBHelper(), you always get the same instance.
  //
  //What is a private constructor?
  // A constructor with a leading underscore (_) is private to the class.
  // This means no other class or part of the app can directly call DBHelper._internal() to create a new instance.
  //
  // Why use a private constructor?
  // It restricts the creation of new instances from outside the class.
  // Only the singleton instance (_instance) can call this constructor.
  //The first time you write DBHelper(), the _instance is created using DBHelper._internal(). On subsequent calls to DBHelper(), the already created _instance is returned, instead of creating a new one.
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();




  //Database Instance Management
  static Database? _database;

  //Getter for Database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  //Initialize the Database
  Future<Database> _initDB(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }





  //Create the Table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    date TEXT
  )
''');
  }




  //CRUD

  //Code for Create Operation
  Future<int> insertNote(Map<String, dynamic> note) async{
    final db = await database;
    return await db.insert(
        'notes',
         note,
         conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //Code for Read Operation
  Future <List<Map<String,dynamic>>> fetchNotes() async{
    final db = await database;
    return await db.query('notes');

  }

  //Code for Update Operation
  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database; // Get database instance
    return await db.update(
      'notes', // Table name
      note, // New data to update
      where: 'id = ?', // Where clause
      whereArgs: [id], // Argument for where clause
    );
  }


  //Code for Delete Operation
  Future<int> deleteNote(int id) async {
    // Get the database instance
    final db = await database;

    // Delete the note from the 'notes' table
    return await db.delete(
      'notes',   // Table name
      where: 'id = ?', // The condition to find the note by id
      whereArgs: [id], // The value for the condition
    );
  }



}
