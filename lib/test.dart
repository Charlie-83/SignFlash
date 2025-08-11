import 'dart:math';

import 'package:bslflash/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TestPage extends StatelessWidget {
  final int id;
  final void Function(bool success) answer;
  final void Function() edit;
  const TestPage({
    super.key,
    required this.id,
    required this.answer,
    required this.edit,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: wordAndAttempts(context, id),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<MapEntry<String, List<bool>>?> word,
          ) {
            if (!word.hasData) {
              return Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  "Add some words to the database",
                  style: TextStyle(fontSize: 30),
                ),
              );
            }
            List<Widget> successIcons = [];
            final v = word.data!.value;
            for (final s in v.sublist(v.length - min(5, v.length))) {
              successIcons.add(
                Icon(
                  s ? Icons.check : Icons.close,
                  color: s ? Colors.green : Colors.red,
                ),
              );
            }
            return Center(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(word.data!.key, style: TextStyle(fontSize: 40)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton.large(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check, color: Colors.black54),
                            onPressed: () {
                              answer(true);
                            },
                          ),
                          FloatingActionButton.large(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, color: Colors.black54),
                            onPressed: () {
                              answer(false);
                            },
                          ),
                          FloatingActionButton.large(
                            child: Icon(Icons.language),
                            onPressed: () async {
                              String w = word.data!.key;
                              w = w.split(RegExp(r"/|\("))[0];
                              w = w.trim();
                              w = w.replaceAll(RegExp(r" "), "-");
                              w = w.replaceAll(RegExp(r"'"), "");
                              final Uri url = Uri.parse(
                                "https://www.signbsl.com/sign/$w",
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: edit,
                      child: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  Future<MapEntry<String, List<bool>>?> wordAndAttempts(
    BuildContext context,
    int id,
  ) async {
    final db = context.watch<Database>();
    String? word = await db.word(id);
    if (word == null) {
      return null;
    }
    List<bool> attempts = await db.attempts(id);
    return MapEntry(word, attempts);
  }
}
