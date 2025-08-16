import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signflash/database.dart';
import 'package:signflash/main.dart';

enum Language { bsl, asl, custom }

class Settings with ChangeNotifier {
  late Future<SharedPreferences> prefs_;
  Settings() {
    initialise();
  }
  Future<void> initialise() async {
    prefs_ = SharedPreferences.getInstance();
  }

  Future<Language> get language async {
    final prefs = await prefs_;
    return Language.values[prefs.getInt("language") ?? 0];
  }

  void updateLanguage(Language l) async {
    prefs_.then((SharedPreferences prefs) {
      prefs.setInt("language", l.index);
      notifyListeners();
    });
  }

  Future<String?> get customUrl async {
    final prefs = await prefs_;
    return prefs.getString("customUrl");
  }

  void updateCustomUrl(String url) async {
    prefs_.then((SharedPreferences prefs) {
      prefs.setString("customUrl", url);
      notifyListeners();
    });
  }

  Future<bool> get isAppInitialised async {
    final prefs = await prefs_;
    return prefs.getBool("isAppInitialised") ?? false;
  }

  void initialiseApp() {
    prefs_.then((SharedPreferences prefs) {
      prefs.setBool("isAppInitialised", true);
      notifyListeners();
    });
  }

  void deinitialiseApp() {
    prefs_.then((SharedPreferences prefs) {
      prefs.remove("isAppInitialised");
      notifyListeners();
    });
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    return FutureBuilder(
      future: settings.language,
      builder: (BuildContext context, AsyncSnapshot<Language> language) {
        if (!language.hasData) return Container();
        List<Widget> rows = [
          const Text("Language", style: TextStyle(fontSize: 20)),
          SegmentedButton<Language>(
            selected: {language.data!},
            onSelectionChanged: (Set<Language> selection) {
              settings.updateLanguage(selection.first);
            },
            showSelectedIcon: false,
            segments: [
              ButtonSegment<Language>(
                value: Language.bsl,
                label: const Text("BSL"),
              ),
              ButtonSegment<Language>(
                value: Language.asl,
                label: const Text("ASL"),
              ),
              ButtonSegment<Language>(
                value: Language.custom,
                label: const Text("Custom"),
              ),
            ],
          ),
        ];
        if (language.data! == Language.custom) {
          rows.add(
            FutureBuilder(
              future: settings.customUrl,
              builder:
                  (BuildContext context, AsyncSnapshot<String?> customUrl) {
                    final controller = TextEditingController(
                      text: customUrl.data,
                    );

                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText:
                                  "Use \"*\" as placeholder for the word",
                              hintText: "https://www.google.com/search?q=*",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                            ),
                          ),
                        ),
                        FloatingActionButton.small(
                          child: Icon(Icons.save),
                          onPressed: () =>
                              settings.updateCustomUrl(controller.text),
                        ),
                      ],
                    );
                  },
            ),
          );
        }
        Database db = context.read<Database>();
        TestIDModel testId = context.read<TestIDModel>();
        rows.addAll([
          SizedBox(height: 30),
          TextButton(
            child: const Text("Import Starter Words"),
            onPressed: () async {
              bool add =
                  (await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Import Start Words"),
                      content: const Text(
                        "This will import over 100 basic words. Would you like to continue?",
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                        TextButton(
                          child: const Text("No"),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ),
                  )) ??
                  false;
              if (add) {
                await db.importLines(
                  (await rootBundle.loadString(
                    "assets/words/basic.txt",
                  )).split("\n"),
                );
                int? nextValid = await db.nextValid(0);
                if (testId.testId == null && nextValid != null) {
                  testId.update(nextValid);
                }
              }
            },
          ),
          TextButton(
            child: const Text("Reset app"),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text("Reset App"),
                content: const Text(
                  "Are you sure you want to delete all words?",
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () {
                      db.reset();
                      testId.update(null);
                      settings.deinitialiseApp();
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
        ]);
        return Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Center(child: Column(children: rows)),
        );
      },
    );
  }
}
