import 'package:flutter/material.dart';

class WordListPage extends StatelessWidget {
  final List<String> words;
  final void Function(int) setEdit;
  const WordListPage({super.key, required this.words, required this.setEdit});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < words.length; ++i) {
      final String w = words[i];
      items.add(
        Padding(
          padding: EdgeInsetsGeometry.only(left: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Expanded(child: Text(w, style: TextStyle(fontSize: 30))),
              FloatingActionButton.small(
                child: Icon(Icons.edit),
                onPressed: () {
                  setEdit(i);
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(children: items);
  }
}
