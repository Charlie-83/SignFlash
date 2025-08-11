import 'dart:math';

import 'dart:io';

import 'package:bslflash/database.dart';
import 'package:bslflash/edit.dart';
import 'package:bslflash/list.dart';
import 'package:bslflash/test.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context) => Database(), child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BSLFlash",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (context) => TestIDModel(),
        child: const HomePage(title: 'BSLFlash'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class TestIDModel with ChangeNotifier {
  int testId = 1;
  void update(int id) {
    testId = id;
    notifyListeners();
  }
}

enum Pages { test, list, edit }

class _HomePageState extends State<HomePage> {
  int? editId;
  Pages page = Pages.test;

  @override
  Widget build(BuildContext context) {
    Widget pageWidget;
    switch (page) {
      case (Pages.test):
        pageWidget = ChangeNotifierProvider(
          create: (context) => TestIDModel(),
          child: TestPage(
            id: context.watch<TestIDModel>().testId,
            answer: (bool success) {
              next(context, success);
            },
            edit: () {
              setState(() {
                page = Pages.edit;
                editId = context.read<TestIDModel>().testId;
              });
            },
          ),
        );
        break;
      case (Pages.list):
        pageWidget = WordListPage(
          setEdit: (int? id) {
            setState(() {
              page = Pages.edit;
              editId = id;
            });
          },
        );
        break;
      case (Pages.edit):
        pageWidget = EditPage(
          id: editId,
          done: () {
            setState(() {
              page = Pages.list;
            });
          },
        );
        break;
    }

    final db = context.read<Database>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: pageWidget,
      floatingActionButton: FloatingActionButton(
        child: Icon(page == Pages.test ? Icons.list : Icons.lightbulb),
        onPressed: () => setState(() {
          if (page == Pages.test) {
            page = Pages.list;
          } else {
            page = Pages.test;
          }
        }),
      ),
      drawer: Drawer(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text("Reset Database"),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Reset Database"),
                  content: const Text(
                    "Are you sure you want to delete all words in the database?",
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        context.read<Database>().reset();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("No"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Export Data"),
              onTap: () async {
                String? dir = await FilePicker.platform.getDirectoryPath();
                if (dir != null) {
                  db.export(dir);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text("Import Data"),
              onTap: () async {
                FilePickerResult? file = await FilePicker.platform.pickFiles();
                if (file != null && file.files[0].path != null) {
                  db.import(File(file.files[0].path!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void next(BuildContext context, bool correct) async {
    var db = context.read<Database>();
    db.newAttempt(context.read<TestIDModel>().testId, correct);
    final attempts = await db.allAttempts();
    final sum = attempts.entries.fold(
      0,
      (count, entry) =>
          count +
          max(
            1,
            entry.value
                .sublist(entry.value.length - min(5, entry.value.length))
                .fold(
                  5 - min(5, entry.value.length),
                  (entryCount, b) => entryCount + (!b ? 1 : 0),
                ),
          ),
    );
    int nextCount = (Random().nextDouble() * sum).toInt();
    int count = 0;
    for (final entry in attempts.entries) {
      count += max(
        1,
        entry.value
            .sublist(entry.value.length - min(5, entry.value.length))
            .fold(
              5 - min(5, entry.value.length),
              (entryCount, b) => entryCount + (!b ? 1 : 0),
            ),
      );
      if (count >= nextCount) {
        setState(() {
          context.read<TestIDModel>().update(entry.key);
        });
        return;
      }
    }
  }
}
