import 'dart:math';

import 'package:bslflash/database.dart';
import 'package:bslflash/edit.dart';
import 'package:bslflash/list.dart';
import 'package:bslflash/test.dart';
import 'package:flutter/material.dart';
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
      home: const HomePage(title: 'BSLFlash'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Pages { test, list, edit }

class _HomePageState extends State<HomePage> {
  int testId = 1;
  int? editId;
  Pages page = Pages.test;

  @override
  Widget build(BuildContext context) {
    Widget pageWidget;
    switch (page) {
      case (Pages.test):
        pageWidget = TestPage(
          id: testId,
          answer: (bool success) {
            next(context, success);
          },
          edit: () {
            setState(() {
              page = Pages.edit;
            });
          },
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
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text("Reset Database"),
              onTap: () => context.read<Database>().reset(),
            ),
          ],
        ),
      ),
    );
  }

  void next(BuildContext context, bool correct) async {
    var db = context.read<Database>();
    db.newAttempt(testId, correct);
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
          testId = entry.key;
        });
        return;
      }
    }
  }
}
