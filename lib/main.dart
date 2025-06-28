import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'BSLFlash'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> words = [];
  Map<String, List<bool>> map = HashMap();
  int index = 0;

  Future<void> asyncInitState() async {
    final dir = Directory('/storage/emulated/0/Download');
    File file = File(p.join(dir.path, "bslflash.txt"));
    if (!(await file.exists())) {
      await file.create();
    }
    setState(() {
      words = file.readAsLinesSync();
      index = Random().nextInt(words.length);
    });

    File stateFile = File('/storage/emulated/0/Documents/bslflash_state.json');
    if (!(await stateFile.exists())) {
      await stateFile.create();
    } else {
      Map<String, dynamic> m = jsonDecode(stateFile.readAsStringSync());
      setState(() {
        map = m.map((key, value) => MapEntry(key, List<bool>.from(value)));
      });
    }

    setState(() {
      for (String w in words) {
        if (!map.containsKey(w)) {
          map[w] = [];
        }
      }
    });
    saveState();
  }

  void saveState() async {
    File stateFile = File('/storage/emulated/0/Documents/bslflash_state.json');
    stateFile.writeAsStringSync(jsonEncode(map));
  }

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void next(bool correct) {
    setState(() {
      final word = words[index];
      map[word]!.add(correct);
      if (map[word]!.length == 6) {
        map[word]!.removeAt(0);
      }
      saveState();

      final padded = map.values.map(
        (l) => l + List.filled(5 - l.length, false),
      );

      int totalWeight =
          padded.expand((l) => l).where((v) => !v).length + map.length;
      int v = Random().nextInt(totalWeight);
      for (int i = 0; i < words.length; i++) {
        var successes = map[words[i]]!;
        successes = successes + List.filled(5 - successes.length, false);
        v -= successes.where((v) => !v).length + 1;
        if (v <= 0) {
          index = i;
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> successIcons = [];
    if (words.isNotEmpty) {
      for (final s in map[words[index]] ?? []) {
        successIcons.add(Icon(s ? Icons.check : Icons.close));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              words.isNotEmpty ? words[index] : "",
              style: TextStyle(fontSize: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.large(
                  child: Icon(Icons.check),
                  onPressed: () {
                    next(true);
                  },
                ),
                FloatingActionButton.large(
                  child: Icon(Icons.close),
                  onPressed: () {
                    next(false);
                  },
                ),
                FloatingActionButton.large(
                  child: Icon(Icons.language),
                  onPressed: () async {
                    String word = words[index];
                    word = word.split(RegExp(r"/|\("))[0];
                    final Uri url = Uri.parse(
                      "https://www.signbsl.com/sign/$word",
                    );
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: successIcons,
            ),
          ],
        ),
      ),
    );
  }
}
