import "dart:io";
import "package:path/path.dart";
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/taks_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;
  String _dbName = "todo.db";
  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  DatabaseHelper._instance();

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDB();
    }

    return _db;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _dbName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $taskTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle TEXT NOT NULL,
        $colDate TEXT,
        $colPriority TEXT,
        $colStatus INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    return db.query(taskTable);
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];

    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    return await db.insert(taskTable, task.toMap());
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    return await db.update(taskTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(id) async {
    Database db = await this.db;
    return await db.delete(taskTable, where: '$colId = ?', whereArgs: [id]);
  }
}
