import 'package:flutter/material.dart';

class WordListPage extends StatelessWidget {
  final List<String> words;
  const WordListPage({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    for (final w in words) {
      items.add(
      Padding(
      padding: EdgeInsetsGeometry.only(left: 20, right:10),
      child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Expanded(child: Text(w, style: TextStyle(fontSize: 30))),
            FloatingActionButton.small(
              child: Icon(Icons.edit),
              onPressed: () {},
            ),
          ],
        )),
      );
    }

    return ListView(children: items);
  }
}
