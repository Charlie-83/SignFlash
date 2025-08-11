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
      future: context.watch<Database>().wordAndAttempts(id),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<MapEntry<String, List<bool>>?> word,
          ) {
            if (!word.hasData && word.connectionState == ConnectionState.done) {
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
            if (word.hasData) {
              final v = word.data!.value;
              for (final s in v.sublist(v.length - min(5, v.length))) {
                successIcons.add(
                  Icon(
                    s ? Icons.check : Icons.close,
                    color: s ? Colors.green : Colors.red,
                  ),
                );
              }
            }
            String wordString = word.hasData ? word.data!.key : "";
            return Center(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(wordString, style: TextStyle(fontSize: 40)),
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
                              wordString = wordString.split(RegExp(r"/|\("))[0];
                              wordString = wordString.trim();
                              wordString = wordString.replaceAll(
                                RegExp(r" "),
                                "-",
                              );
                              wordString = wordString.replaceAll(
                                RegExp(r"'"),
                                "",
                              );
                              final Uri url = Uri.parse(
                                "https://www.signbsl.com/sign/$wordString",
                              );
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalNonBrowserApplication,
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: successIcons,
                        ),
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
}
