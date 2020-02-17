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
      options TEXT,
      extras TEXT,
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
    final createLocTable = '''CREATE TABLE locations
    (
      id INTEGER PRIMARY KEY autoincrement,
      lat REAL,
      lon REAL,
      accuracy REAL,
      timestamp TEXT
    )''';

    await db.execute(createQATable).then((value){print('created table authQAs');});
    await db.execute(createToDoTable).then((value){print('created table todos');});
    await db.execute(createLocTable).then((value){print('created table todos');});
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
    //print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createTables(db);
  }

  Future<List> getQAs() async {
    final sql = '''SELECT * FROM authQAs
    WHERE isDeleted = 0''';
    final data = await db.rawQuery(sql);
    List qas = List();

    for (final node in data) {
      final todo = AuthQA.fromJson(node);
      qas.add(todo);
    }
    return qas;
  }

  Future<void> addQA(AuthQA authQA) async {
    final sql = '''INSERT INTO authQAs
    (
      id,
      type,
      question,
      options,
      extras,
      isDeleted
    )
    VALUES (?,?,?,?,?,?)''';
    List<dynamic> params = [authQA.id, authQA.type, authQA.question, authQA.options, authQA.extras, authQA.isDeleted ? 1 : 0];
    final result = await db.rawInsert(sql, params);
    databaseLog('Add qa', sql, null, result, params);
    return result;
  }
  
  Future qaBatchInsert(qAList) async{
    final batch = db.batch();
    qAList.forEach((qa) => batch.insert('authQAs', {
      'type': qa.type,
      'question': qa.question,
      'options': qa.options,
      'extras': qa.extras,
      'isDeleted': qa.isDeleted
    }));
    return await batch.commit();
  }

  Future deleteOldCallQA() async{
    return  await db.rawDelete('DELETE FROM authQAs WHERE type = ? OR type = ? OR type = ?', [1, 2, 3]);
  }
  Future deleteOldLOCQA() async{
    int limit = 4;
    final sql = '''SELECT * FROM authQAs WHERE type = 4''';
    final data = await db.rawQuery(sql);
    if(data.length > limit){
      print('got ${data.length} rows for location');
      int diff = data.length - limit;
      //final newSql = 'DELETE FROM authQAs WHERE id IN (SELECT id FROM authQAs WHERE type = ? LIMIT ?)';

      //return await db.rawQuery(newSql, [4, diff]);
      //await db.rawDelete('DELETE FROM authQAs WHERE id IN (SELECT id FROM authQAs WHERE type = ? LIMIT ?)', [4, diff]);
      final data1 = await db.rawQuery('SELECT id FROM authQAs WHERE type = 4 LIMIT ?', [diff]);
      String toDelete = "(";
      
        data1.forEach((e){
          if(toDelete == "(")
            toDelete = toDelete + "${e['id']}";
          else
            toDelete = toDelete + ",${e['id']}";
        });
      
      
      toDelete = toDelete + ")";
      print('got data1 $toDelete');
      //return Future.value('done');

      await db.rawQuery('DELETE FROM authQAs WHERE id IN $toDelete').then((value){
        print('after delete $value');
        return Future.value('done');
      });
      
    }else return Future.value('done');
  }

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
    //print('init insert');
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
    //print(result);
    databaseLog('Add todo', sql, null, result, params);
    return result;
  }
  Future updateTodo(Todo todo) async{
    final sql = '''UPDATE todos SET status = ? WHERE id = ?''';
    final result = await db.rawUpdate(sql, [todo.status, todo.id]);
    return result;
  }

  Future deleteTodo(id) async {
    final result = await db.rawDelete('DELETE FROM todos WHERE id = ?', [id]);
    return result;
  }

  Future getLocations() async{
    final sql = '''SELECT * FROM locations''';
    final data = await db.rawQuery(sql);
    //print('got locations $data');
    return data;
  }
  Future addLocation(loc) async{
    final sql = '''INSERT INTO locations
    (
      lat,
      lon,
      accuracy,
      timestamp
    )
    VALUES (?,?,?,?)
    ''';
    List params = [loc['lat'], loc['lon'], loc['accuracy'], loc['timestamp'].toString()];
    final result = await db.rawInsert(sql, params);
    return result;
  }

  Future deleteBatchLocs(ids) async{
    final batch = db.batch();
    ids.forEach((id) => batch.delete('locations', where: 'id = ?', whereArgs: [id]));
    return await batch.commit();
  }
}