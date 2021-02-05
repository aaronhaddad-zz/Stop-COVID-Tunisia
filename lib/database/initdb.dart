import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Initdb {
  static final _databaseName = "user.db";
  static final _databaseVersion = 1;

  static final table = 'user';

  static final columnId = '_id';
  static final columnemail = '_email';
  static final columnmac = '_mac';
  static final columnuserId = '_userId';
  static final columninfected = '_infected';
  static final pushkey = '_pushkey';
  static final firstNameColumn = '_firstname';
  static final lastNameColumn = '_lastname';
  static final firstTimeInColumn = '_firsttimeincolumn';
  static final scanRemindersColumn = '_scanreminderscolumn';
  static final suspectedColumn = '_suspectedcolumn';
  static final dateColumn = '_datecolumn';

  Initdb._privateConstructor();
  static final Initdb instance = Initdb._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initializeDb();
    return _database;
  }

  _initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnemail TEXT NOT NULL,
            $columnmac TEXT NOT NULL,
            $columnuserId TEXT NOT NULL,
            $columninfected INTEGER NOT NULL,
            $pushkey TEXT,
            $firstNameColumn TEXT,
            $lastNameColumn TEXT,
            $firstTimeInColumn TEXT,
            $scanRemindersColumn TEXT,
            $suspectedColumn TEXT,
            $dateColumn TEXT
          )
          ''');
  }

  Future rmDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, _databaseName);
    await deleteDatabase(path);
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  //This future is used to simplify seeing the content of the DB
  Future<List> dbContent() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list;
  }

  //This series of future will help retrive specific data
  Future<String> email() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_email'];
  }

  Future<String> mac() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_mac'];
  }

  Future<String> uid() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_userId'];
  }

  Future<int> infection() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_infected'];
  }

  Future<String> pushkeyDb() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_pushkey'];
  }

  Future<String> firstNameDb() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_firstname'];
  }

  Future<String> lastNameDb() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_lastname'];
  }

  Future<String> firstTimeIn() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_firsttimeincolumn'];
  }

  Future<String> reminderBool() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_scanreminderscolumn'];
  }

  Future<String> suspected() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_suspectedcolumn'];
  }

  Future<String> date() async {
    Database db = await instance.database;
    List<Map> list = await db.rawQuery('SELECT * FROM user');
    return list[0]['_datecolumn'];
  }
}
