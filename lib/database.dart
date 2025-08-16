import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class Database with ChangeNotifier {
  late Future<sql.Database> db_;

  Database() {
    db_ = initalise();
  }

  Future<List<bool>> attempts(int id) async {
    var db = await db_;
    final attemptsQ = await db.query(
      "Vocab",
      where: "id = ?",
      whereArgs: [id],
      columns: ["attempts"],
    );
    if (attemptsQ.length != 1) {
      return [];
    }
    final attemptsS = attemptsQ[0]["attempts"];
    if (attemptsS is String) {
      return attemptsS.toString().split("").map((c) => c == "1").toList();
    } else {
      return [];
    }
  }

  Future<Map<int, List<bool>>> allAttempts() async {
    var db = await db_;
    final attemptsQ = await db.query("Vocab", columns: ["id", "attempts"]);
    Map<int, List<bool>> out = attemptsQ.fold({}, (map, row) {
      map[row["id"] as int] = row["attempts"]
          .toString()
          .split("")
          .map((c) => c == "1")
          .toList();
      return map;
    });
    return out;
  }

  Future<void> export() async {
    var db = await db_;
    final queryResult = await db.query("Vocab", columns: ["word"]);
    final bytes = utf8.encode(
      queryResult.map((cols) => cols["word"].toString()).join("\n"),
    );
    FilePicker.platform.saveFile(
      fileName: "signflash_export.txt",
      bytes: bytes,
    );
  }

  Future<void> importFile(File file) async {
    final lines = file.readAsLinesSync();
    importLines(lines);
  }

  Future<void> importLines(List<String> lines) async {
    var db = await db_;
    for (final line in lines) {
      if (line == "") continue;
      db.insert("Vocab", {"word": line, "attempts": ""});
    }
    notifyListeners();
  }

  Future<sql.Database> initalise() async {
    return await sql.openDatabase(
      'signflash.db',
      version: 1,
      onCreate: (sql.Database db, int version) async {
        await db.execute(
          "CREATE TABLE Vocab (id INTEGER PRIMARY KEY, word TEXT, attempts TEXT)",
        );
      },
    );
  }

  Future<void> newAttempt(int id, bool success) async {
    var db = await db_;
    final attemptsQ = await db.query(
      "Vocab",
      where: "id = ?",
      whereArgs: [id],
      columns: ["attempts"],
    );
    if (attemptsQ.length != 1) return;
    final attempts = attemptsQ[0]["attempts"];
    if (attempts is String) {
      db.update(
        "Vocab",
        {"attempts": attempts.toString() + (success ? "1" : "0")},
        where: "id = ?",
        whereArgs: [id],
      );
    }
    notifyListeners();
  }

  Future<int> updateOrAddWord(int? id, String word) async {
    var db = await db_;
    if (id == null) {
      return db.insert("Vocab", {"word": word, "attempts": ""});
    } else {
      return db.update(
        "Vocab",
        where: "id = ?",
        whereArgs: [id],
        {"word": word},
      );
    }
  }

  Future<String?> word(int id) async {
    var db = await db_;
    final queryResult = await db.query(
      "Vocab",
      where: "id = ?",
      whereArgs: [id],
      columns: ["word"],
    );
    if (queryResult.length != 1) {
      return null;
    }
    return queryResult[0]["word"].toString();
  }

  Future<int> wordCount() async {
    var db = await db_;
    return (await db.query("Vocab")).length;
  }

  Future<Map<int, String>> words() async {
    var db = await db_;
    Map<int, String> out = (await db.query("Vocab", columns: ["id", "word"]))
        .fold({}, (map, word) {
          map[word["id"] as int] = word["word"].toString();
          return map;
        });
    return out;
  }

  Future<void> reset() async {
    var db = await db_;
    db.delete("Vocab");
    notifyListeners();
  }

  Future<void> deleteRow(int id) async {
    var db = await db_;
    db.delete("Vocab", where: "id = ?", whereArgs: [id]);
  }

  Future<MapEntry<String, List<bool>>?> wordAndAttempts(int id) async {
    var db = await db_;
    final queryResult = await db.query(
      "Vocab",
      where: "id = ?",
      whereArgs: [id],
      columns: ["word", "attempts"],
    );
    if (queryResult.length != 1) {
      return null;
    }
    return MapEntry(
      queryResult[0]["word"].toString(),
      queryResult[0]["attempts"]
          .toString()
          .split("")
          .map((c) => c == "1")
          .toList(),
    );
  }

  Future<Map<int, MapEntry<String, List<bool>>>> allWordAndAttempts() async {
    var db = await db_;
    final queryResult = await db.query(
      "Vocab",
      columns: ["id", "word", "attempts"],
    );
    Map<int, MapEntry<String, List<bool>>> out = queryResult.fold({}, (
      map,
      row,
    ) {
      map[row["id"] as int] = MapEntry(
        row["word"].toString(),
        row["attempts"].toString().split("").map((c) => c == "1").toList(),
      );
      return map;
    });
    return out;
  }

  Future<int?> nextValid(int id) async {
    var db = await db_;
    final queryResult = await db.query("Vocab", columns: ["id"], orderBy: "id");
    for (final row in queryResult) {
      int newId = row["id"] as int;
      if (newId > id) {
        return newId;
      }
    }
    if (queryResult.isNotEmpty) {
      return queryResult[0]["id"] as int;
    }
    return null;
  }
}
