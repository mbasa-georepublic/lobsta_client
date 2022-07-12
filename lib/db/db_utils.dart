import 'dart:io' show Directory;

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  static Database? _db;

  Future<Database?> get _dataBase async {
    _db ??= await _initDb();
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
        version: 2,
        readOnly: false,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);

    return tDb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Updating Database Tables");

    Map<String, List<String>> updateSql = {
      "2": [
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
    };

    for (int i = oldVersion + 1; i <= newVersion; i++) {
      try {
        if (updateSql[i.toString()]!.isNotEmpty) {
          for (String st in updateSql[i.toString()]!) {
            await db.execute(st);
          }
        }
      } catch (e) {
        debugPrint("ALTER Table: ${e.toString()}");
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
  }

  Future<int> deleteUserCredential() async {
    var db = await _dataBase;
    return await db!.delete("user_credential");
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
      await db!.insert(
        "logged_credentials",
        tabData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return await db!.insert(
      "user_credential",
      tabData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getUserToken() async {
    String retVal = "";

    var db = await _dataBase;
    var res = await db!.query("user_credential", limit: 1);

    if (res.isNotEmpty) {
      retVal = res[0]["redmine_token"].toString();
    }

    return retVal;
  }

  Future<Map<String, Object?>> getUserCredential() async {
    Map<String, Object?> retVal = {};

    var db = await _dataBase;
    var res = await db!.query("user_credential", limit: 1);

    if (res.isNotEmpty) {
      retVal = res[0];
    }

    return retVal;
  }

  Future<List<Map<String, Object?>>> getLoggedCredentials() async {
    List<Map<String, Object?>> retVal = [];

    var db = await _dataBase;
    var res = await db!.query("logged_credentials",
        where: "username || url not in "
            "(select username || url from user_credential)");

    if (res.isNotEmpty) {
      retVal = res;
    }

    return retVal;
  }

  Future<int> deleteLoggedCredential(String username, String url) async {
    var db = await _dataBase;
    return await db!.delete("logged_credentials",
        where: "username = ? and url = ?", whereArgs: [username, url]);
  }
}
