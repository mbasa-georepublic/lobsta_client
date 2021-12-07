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
        version: 1, readOnly: false, onCreate: _onCreate);

    return tDb;
  }

  void _onCreate(Database db, int version) async {
    debugPrint("Creating Database Tables");

    db.execute("CREATE TABLE user_credential("
        "username TEXT PRIMARY KEY,"
        "password TEXT,"
        "url TEXT,"
        "redmine_token TEXT);");
  }

  Future<int> deleteUserCredential() async {
    var db = await _dataBase;
    return await db!.delete("user_credential");
  }

  Future<int> insertUserCredential(
      String user, String password, String url, String token) async {
    var db = await _dataBase;

    return await db!.insert("user_credential", {
      "username": user,
      "password": password,
      "url": url,
      "redmine_token": token,
    });
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

  Future<Map<String,Object?>> getUserCredential() async {
    Map<String,Object?> retVal = {};

    var db = await _dataBase;
    var res = await db!.query("user_credential", limit: 1);

    if (res.isNotEmpty) {
      retVal = res[0];
    }

    return retVal;
  }
}
