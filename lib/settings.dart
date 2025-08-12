import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { bsl, asl }

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
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SegmentedButton<Language>(
            selected: {context.watch<Settings>().language},
            onSelectionChanged: (Set<Language> selection) {
              context.read<Settings>().updateLanguage(selection.first);
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
            ],
          ),
        ],
      ),
    );
  }
}
