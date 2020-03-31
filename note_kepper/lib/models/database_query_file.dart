import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/models/map_data.dart';

class DatabaseHelper {
  // here we write SQL queries and also specify path for storage

  String dataTable = 'note_table';
  String attributeId = 'primaryKey';
  String attributePriority = 'priority';
  String attributeTitle = 'title';
  String attributeDescription = 'description';

  String attributeDate = 'date';
  static DatabaseHelper _databaseHelper;
  static Database _database;

  DatabaseHelper._createInstance(); // instance of databaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); //  executed only once
    }
    return _databaseHelper;
  }

  Future<Database> setPath() async {
    // Get the directory path  store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createTable);
    return notesDatabase;
  }

  void _createTable(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $dataTable($attributeId INTEGER PRIMARY KEY AUTOINCREMENT, $attributeTitle TEXT, '
        '$attributeDescription TEXT, $attributePriority INTEGER, $attributeDate TEXT)');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await setPath();
    }
    return _database;
  }

  // Get all note objects from database in ascending order
  Future<List<Map<String, dynamic>>> getMapList() async {
    Database database = await this.database;

    var result = await database
        .rawQuery('SELECT * FROM $dataTable order by $attributePriority ASC');

    return result;
  }

  // Insert Operation:
  Future<int> insertNote(NoteData note) async {
    Database database = await this.database;
    var result = await database.insert(dataTable, note.dataToMap());
    return result;
  }

  Future<int> deleteNote(int primaryKey) async {
    var database = await this.database;
    int result = await database
        .rawDelete('DELETE FROM $dataTable WHERE $attributeId = $primaryKey');
    return result;
  }

  // Update
  Future<int> updateNote(NoteData note) async {
    var database = await this.database;
    var result = await database.update(dataTable, note.dataToMap(),
        where: '$attributeId = ?', whereArgs: [note.primaryKey]);
    return result;
  }

  // Delete

  // Get number of notes
  Future<int> getCount() async {
    Database database = await this.database;
    List<Map<String, dynamic>> x =
        await database.rawQuery('SELECT COUNT (*) from $dataTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<NoteData>> getNoteList() async {
    var mapList = await getMapList(); // Get 'Map List' from database
    int count = mapList.length;

    List<NoteData> noteList = List<NoteData>();
    //loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(NoteData.mapToData(mapList[i]));
    }

    return noteList;
  }
}
