import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import './../models/authQA.dart';
import './../providers/appState.dart';

Database db;
class SqlService {

  static const authQATable = 'authQAs';
  static const id = 'id';
  static const type = 'type';
  static const question = 'question';
  static const answer = 'answer';
  static const isDeleted = 'isDeleted';

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

  Future<void> createAuthQAsTable(Database db) async {
    final todoSql = '''CREATE TABLE $authQATable
    (
      $id INTEGER PRIMARY KEY,
      $type INTEGER,
      $question TEXT,
      $answer TEXT,
      $isDeleted BIT NOT NULL
    )''';

    await db.execute(todoSql);
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
    await createAuthQAsTable(db);
  }

  static Future<List> getAllTodos() async {
    final sql = '''SELECT * FROM ${authQATable}
    WHERE ${isDeleted} = 0''';
    final data = await db.rawQuery(sql);
    List qas = List();

    for (final node in data) {
      final todo = AuthQA.fromJson(node);
      qas.add(todo);
    }
    return qas;
  }

  static Future<void> addTodo(AuthQA authQA) async {
    /*final sql = '''INSERT INTO ${DatabaseCreator.todoTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.info},
      ${DatabaseCreator.isDeleted}
    )
    VALUES 
    (
      ${todo.id},
      "${todo.name}",
      "${todo.info}",
      ${todo.isDeleted ? 1 : 0}
    )''';*/

    final sql = '''INSERT INTO ${authQATable}
    (
      ${id},
      ${type},
      ${question},
      ${answer},
      ${isDeleted}
    )
    VALUES (?,?,?,?,?)''';
    List<dynamic> params = [authQA.id, authQA.type, authQA.question, authQA.answer, authQA.isDeleted ? 1 : 0];
    final result = await db.rawInsert(sql, params);
    databaseLog('Add todo', sql, null, result, params);
  }

}