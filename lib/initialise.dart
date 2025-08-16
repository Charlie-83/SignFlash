import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:signflash/database.dart';
import 'package:signflash/main.dart';
import 'package:signflash/settings.dart';

class InitialisePage extends StatefulWidget {
  const InitialisePage({super.key});

  @override
  State<InitialisePage> createState() {
    return _InitialisePageState();
  }
}

class _InitialisePageState extends State<InitialisePage> {
  _Stages stage = _Stages.selectLanguage;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (stage) {
      case (_Stages.selectLanguage):
        body = Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Select a language", style: TextStyle(fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  child: Text("BSL", style: TextStyle(fontSize: 30)),
                  onPressed: () {
                    context.read<Settings>().updateLanguage(Language.bsl);
                    stage = _Stages.importBasicWordSet;
                  },
                ),
                SizedBox(width: 20),
                FloatingActionButton.large(
                  child: Text("ASL", style: TextStyle(fontSize: 30)),
                  onPressed: () {
                    context.read<Settings>().updateLanguage(Language.asl);
                    stage = _Stages.importBasicWordSet;
                  },
                ),
              ],
            ),
          ],
        );
        break;
      case (_Stages.importBasicWordSet):
        Database db = context.read<Database>();
        Settings settings = context.read<Settings>();
        TestIDModel testId = context.read<TestIDModel>();
        body = Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Would you like to import a basic set of words to start?",
              style: TextStyle(fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.large(
                  child: Icon(Icons.check),
                  onPressed: () async {
                    await db.importLines(
                      (await rootBundle.loadString(
                        "assets/words/basic.txt",
                      )).split("\n"),
                    );
                    int? nextValid = await db.nextValid(0);
                    if (testId.testId == null && nextValid != null) {
                      testId.update(nextValid);
                    }
                    settings.initialiseApp();
                  },
                ),
                SizedBox(width: 20),
                FloatingActionButton.large(
                  child: Icon(Icons.delete),
                  onPressed: () {
                    settings.initialiseApp();
                  },
                ),
              ],
            ),
          ],
        );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("SignFlash"),
      ),
      body: Padding(padding: EdgeInsetsGeometry.all(20), child: body),
    );
  }
}

enum _Stages { selectLanguage, importBasicWordSet }
