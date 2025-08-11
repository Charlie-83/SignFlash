import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Language { bsl, asl }

class Settings with ChangeNotifier {
  Language language = Language.bsl;
  void updateLanguage(Language l) {
    language = l;
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
