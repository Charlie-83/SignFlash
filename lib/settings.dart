import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { bsl, asl, custom }

class Settings with ChangeNotifier {
  SharedPreferences? prefs;
  Settings() {
    initialise();
  }
  Future<void> initialise() async {
    prefs = await SharedPreferences.getInstance();
  }

  Language get language {
    if (prefs == null) return Language.bsl;
    return Language.values[prefs!.getInt("language") ?? 0];
  }

  void updateLanguage(Language l) async {
    if (prefs == null) return;
    await prefs!.setInt("language", l.index);
    notifyListeners();
  }

  String? get customUrl {
    if (prefs == null) return null;
    return prefs!.getString("customUrl");
  }

  void updateCustomUrl(String url) async {
    if (prefs == null) return;
    await prefs!.setString("customUrl", url);
    notifyListeners();
  }

  bool get isAppInitialised {
    if (prefs == null) return false;
    return prefs!.getBool("isAppInitialised") ?? false;
  }

  void initialiseApp() {
    prefs!.setBool("isAppInitialised", true);
    notifyListeners();
  }

  void deinitialiseApp() {
    prefs!.remove("isAppInitialised");
    notifyListeners();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Settings settings = context.watch<Settings>();
    List<Widget> rows = [
      const Text("Language", style: TextStyle(fontSize: 20)),
      SegmentedButton<Language>(
        selected: {settings.language},
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
    if (settings.language == Language.custom) {
      final controller = TextEditingController(text: settings.customUrl);
      rows.add(
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Use \"*\" as placeholder for the word",
                  hintText: "https://www.google.com/search?q=*",
                ),
              ),
            ),
            FloatingActionButton.small(
              child: Icon(Icons.save),
              onPressed: () => settings.updateCustomUrl(controller.text),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Center(child: Column(children: rows)),
    );
  }
}
