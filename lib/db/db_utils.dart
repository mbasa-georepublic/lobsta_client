import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  static late Database _db;
  static bool _isInitialized = false;

  Future<Database> get _dataBase async {
    if (!_isInitialized) {
      _db = await _initDb();
      _isInitialized = true;
    }

    return _db;
  }

  dynamic _initDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    String dirPath = "";

    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      dirPath = documentsDirectory.path;
    } catch (e) {
      debugPrint("InitDB Error: ${e.toString()}");
    }

    String path = join(dirPath, "lobsta_client.db");
    debugPrint("InitDB: Using DB in $path");

    var tDb = await openDatabase(path,
        version: 3,
        readOnly: false,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);

    return tDb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("** Updating Database Tables $oldVersion $newVersion **");

    /*
    Map<String, List<String>> updateSql = <String, List<String>>{};
     */
    Map<int, List<String>> updateSql = {
      2: [
        "ALTER TABLE user_credential ADD COLUMN last_name TEXT;",
        "ALTER TABLE user_credential ADD COLUMN first_name TEXT;",
        "CREATE TABLE logged_credentials("
            "username TEXT,"
            "password TEXT,"
            "url TEXT,"
            "last_name TEXT,"
            "first_name TEXT,"
            "redmine_token TEXT,"
            "PRIMARY KEY(username,url) );",
      ],
      3: ["CREATE TABLE tracker_icons(tracker_id INT PRIMARY KEY,icon TEXT);"],
    };

    for (int i = 1; i <= newVersion; i++) {
      if (updateSql.containsKey(i)) {
        for (String st in updateSql[i] ?? []) {
          debugPrint(st);
          try {
            await db.execute(st);
          } catch (e) {
            debugPrint("Update Error: ${e.toString()}");
          }
        }
      }
    }
  }

  void _onCreate(Database db, int version) async {
    debugPrint("Creating Database Tables");

    await db.execute("CREATE TABLE user_credential("
        "username TEXT PRIMARY KEY,"
        "password TEXT,"
        "url TEXT,"
        "last_name TEXT,"
        "first_name TEXT,"
        "redmine_token TEXT);");

    await db.execute("CREATE TABLE logged_credentials("
        "username TEXT,"
        "password TEXT,"
        "url TEXT,"
        "last_name TEXT,"
        "first_name TEXT,"
        "redmine_token TEXT,"
        "PRIMARY KEY(username,url) );");

    await db.execute("CREATE TABLE tracker_icons("
        "tracker_id INT PRIMARY KEY,icon TEXT);");
  }

  Future<int> insertTrackerIcon(int id, String iconName) async {
    var db = await _dataBase;
    int retVal = 0;
    Map<String, dynamic> rec = {"id": id, "icon": iconName};

    try {
      retVal = await db.insert("tracker_icons", rec);
    } catch (e) {
      debugPrint("Tracker Icon: ${e.toString()}");
    }

    return retVal;
  }

  Future<int> deleteTrackerIcons() async {
    var db = await _dataBase;

    return db.delete("tracker_icons");
  }

  Future<int> deleteUserCredential() async {
    var db = await _dataBase;
    return await db.delete("user_credential");
  }

  Future<int> insertUserCredential(
    String user,
    String password,
    String url,
    String lastName,
    String firstName,
    String token, {
    bool insertLog = true,
  }) async {
    var db = await _dataBase;

    Map<String, dynamic> tabData = {
      "username": user,
      "password": password,
      "url": url,
      "last_name": lastName,
      "first_name": firstName,
      "redmine_token": token,
    };

    if (insertLog) {
      await db.insert(
        "logged_credentials",
        tabData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return await db.insert(
      "user_credential",
      tabData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getUserToken() async {
    String retVal = "";

    var db = await _dataBase;
    var res = await db.query("user_credential", limit: 1);

    if (res.isNotEmpty) {
      retVal = res[0]["redmine_token"].toString();
    }

    return retVal;
  }

  Future<Map<String, Object?>> getUserCredential() async {
    Map<String, Object?> retVal = {};

    var db = await _dataBase;
    var res = await db.query("user_credential", limit: 1);

    if (res.isNotEmpty) {
      retVal = res[0];
    }

    return retVal;
  }

  Future<List<Map<String, Object?>>> getLoggedCredentials() async {
    List<Map<String, Object?>> retVal = [];

    var db = await _dataBase;
    var res = await db.query("logged_credentials",
        where: "username || url not in "
            "(select username || url from user_credential)");

    if (res.isNotEmpty) {
      retVal = res;
    }

    return retVal;
  }

  Future<int> deleteLoggedCredential(String username, String url) async {
    var db = await _dataBase;
    return await db.delete("logged_credentials",
        where: "username = ? and url = ?", whereArgs: [username, url]);
  }
}
