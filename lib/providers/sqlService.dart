import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import './../models/authQA.dart';
import './../models/todo.dart';
import './../providers/appState.dart';

Database db;
class SqlService {

  // static const authQATable = 'authQAs';
  // static const id = 'id';
  // static const type = 'type';
  // static const question = 'question';
  // static const answer = 'answer';
  // static const isDeleted = 'isDeleted';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult, int insertAndUpdateQueryResult, List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createTables(Database db) async {
    final createQATable = '''CREATE TABLE authQAs
    (
      id INTEGER PRIMARY KEY autoincrement,
      type INTEGER,
      question TEXT,
      answer TEXT,
      isDeleted BIT NOT NULL
    )''';
    final createToDoTable = '''CREATE TABLE todos
    (
      id INTEGER PRIMARY KEY autoincrement,
      title TEXT,
      description TEXT,
      status INTEGER,
      isDeleted BIT NOT NULL
    )''';

    await db.execute(createQATable).then((value){print('created table authQAs');});
    await db.execute(createToDoTable).then((value){print('created table todos');});
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      //await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('secureLocalDb');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTables(db);
  }

  // static Future<List> getQAs() async {
  //   final sql = '''SELECT * FROM authQAs
  //   WHERE isDeleted = 0''';
  //   final data = await db.rawQuery(sql);
  //   List qas = List();

  //   for (final node in data) {
  //     final todo = AuthQA.fromJson(node);
  //     qas.add(todo);
  //   }
  //   return qas;
  // }

  // static Future<void> addQA(AuthQA authQA) async {
  //   final sql = '''INSERT INTO authQAs
  //   (
  //     id,
  //     type,
  //     question,
  //     answer,
  //     isDeleted
  //   )
  //   VALUES (?,?,?,?,?)''';
  //   List<dynamic> params = [authQA.id, authQA.type, authQA.question, authQA.answer, authQA.isDeleted ? 1 : 0];
  //   final result = await db.rawInsert(sql, params);
  //   databaseLog('Add qa', sql, null, result, params);
  // }

  Future<List> getTodos() async {
    final sql = '''SELECT * FROM todos
    WHERE isDeleted = 0''';
    final data = await db.rawQuery(sql);
    List todos = List();

    for (final node in data) {
      final todo = Todo.fromJson(node);
      todos.add(todo);
    }
    return todos;
  }

  Future<void> addTodo(Todo todo) async {
    print('init insert');
    final sql = '''INSERT INTO todos
    (
      id,
      title,
      description,
      status,
      isDeleted
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [todo.id, todo.title, todo.description, todo.status, todo.isDeleted ? 1 : 0];
    final result = await db.rawInsert(sql, params);
    print(result);
    databaseLog('Add todo', sql, null, result, params);
  }
  Future updateTodo(Todo todo) async{
    final sql = '''UPDATE todos SET status = ? WHERE id = ?''';
    final result = await db.rawUpdate(sql, [todo.status, todo.id]);
  }

  Future deleteTodo(id) async {
    final result = await db.rawDelete('DELETE FROM todos WHERE id = ?', [id]);
    return result;
  }
}