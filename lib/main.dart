import 'dart:io';
import 'dart:math';

import 'package:signflash/database.dart';
import 'package:signflash/edit.dart';
import 'package:signflash/list.dart';
import 'package:signflash/settings.dart';
import 'package:signflash/test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SignFlash",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => Database(),
        builder: (BuildContext context, Widget? _) => FutureBuilder(
          future: context.read<Database>().allAttempts(),

          builder:
              (
                BuildContext context,
                AsyncSnapshot<Map<int, List<bool>>> attempts,
              ) {
                if (attempts.hasData) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (_) => TestIDModel(
                          testId: attempts.data!.isNotEmpty
                              ? next(attempts.data!)
                              : null,
                        ),
                      ),
                      ChangeNotifierProvider(create: (_) => Settings()),
                    ],
                    builder: (BuildContext context, Widget? _) =>
                        HomePage(title: 'SignFlash'),
                  );
                }
                return Container();
              },
        ),
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

enum Pages { test, list, edit, settings }

class TestIDModel with ChangeNotifier {
  // This is in a model so that it can be changed by the edit page when the current testId is deleted
  int? testId;
  TestIDModel({required this.testId});
  void update(int? id) {
    testId = id;
    notifyListeners();
  }
}

class _HomePageState extends State<HomePage> {
  int? editId;
  Pages page = Pages.test;
  Pages previousPage =
      Pages.test; // Just used to go back to test/list after edit

  @override
  Widget build(BuildContext context) {
    Widget pageWidget;
    switch (page) {
      case (Pages.test):
        pageWidget = TestPage(
          id: context.watch<TestIDModel>().testId,
          answer: (bool success) async {
            var db = context.read<Database>();
            TestIDModel testIDModel = context.read<TestIDModel>();
            if (testIDModel.testId != null) {
              db.newAttempt(testIDModel.testId!, success);
            }
            int? newId = await nextAsync(context);
            if (newId == testIDModel.testId) {
              newId = await db.nextValid(newId);
            }
            testIDModel.update(newId);
          },
          edit: () {
            setState(() {
              page = Pages.edit;
              previousPage = Pages.test;
              editId = context.read<TestIDModel>().testId;
            });
          },
        );
        break;
      case (Pages.list):
        pageWidget = WordListPage(
          setEdit: (int? id) {
            setState(() {
              page = Pages.edit;
              previousPage = Pages.list;
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
              page = previousPage;
            });
          },
        );
        break;
      case (Pages.settings):
        pageWidget = SettingsPage();
        break;
    }

    final db = context.read<Database>();
    final testId = context.read<TestIDModel>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(pageName(page)),
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
      drawer: NavigationDrawer(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Delete all words"),
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
                      db.reset();
                      testId.update(null);
                      Navigator.of(context).pop();
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
              db.export();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text("Import Data"),
            onTap: () async {
              FilePickerResult? file = await FilePicker.platform.pickFiles();
              if (file != null && file.files[0].path != null) {
                db.import(File(file.files[0].path!));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () async {
              setState(() {
                page = Pages.settings;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

Future<int> nextAsync(BuildContext context) async {
  var db = context.read<Database>();
  final attempts = await db.allAttempts();
  return next(attempts);
}

int next(Map<int, List<bool>> attempts) {
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
      return entry.key;
    }
  }
  return 1;
}

String pageName(Pages page) {
  switch (page) {
    case (Pages.test):
      return "SignFlash";
    case (Pages.list):
      return "Words";
    case (Pages.edit):
      return "Edit";
    case (Pages.settings):
      return "Settings";
  }
}
