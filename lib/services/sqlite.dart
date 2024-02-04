import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../consts/pin.dart';

class SQLiteService {
  /// Συνάρτηση που φτιάχνει την βάση
  Future<Database> initDB() async {
    return openDatabase(p.join(await getDatabasesPath(), 'travelly.db'),
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE pins(id INTEGER PRIMARY KEY AUTOINCREMENT, lat DOUBLE NOT NULL, long DOUBLE NOT NULL, title TEXT NOT NULL, images BLOB)');
    }, version: 1);
  }

  /// Συνάρτηση που διαβάζει την βάση (και το κάνει μία λίστα)
  Future<List<Pin>> getPins() async {
    final db = await initDB();

    final List<Map<String, Object?>> queryResult = await db.query('pins');
    return queryResult.map((e) => Pin.fromMap(e)).toList();
  }

  Future addPins(Pin pin) async {
    final db = await initDB();

    return db.insert('pins', pin.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deletePins(final id) async {
    final db = await initDB();

    await db.delete('pins', where: 'id = ?', whereArgs: [id]);
  }
}
