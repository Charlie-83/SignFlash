import 'package:flutter/material.dart';

class WordListPage extends StatefulWidget {
  final List<String> words;
  final void Function(int) setEdit;
  const WordListPage({super.key, required this.words, required this.setEdit});

  @override
  State<StatefulWidget> createState() {
    return WordListPageState();
  }
}

class WordListPageState extends State<WordListPage> {
  String search = "";
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.add(
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: "Search"),
              controller: controller,
              onChanged: (String s) {
                setState(() {
                  search = s;
                });
              },
            ),
          ),
          FloatingActionButton.small(
            child: Icon(Icons.add),
            onPressed: () {
              widget.setEdit(-1);
            },
          ),
        ],
      ),
    );
    for (int i = 0; i < widget.words.length; ++i) {
      final String w = widget.words[i];
      if (search == "" ||
          search.toLowerCase().allMatches(w.toLowerCase()).isNotEmpty) {
        items.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Expanded(child: Text(w, style: TextStyle(fontSize: 30))),
              FloatingActionButton.small(
                child: Icon(Icons.edit),
                onPressed: () {
                  widget.setEdit(i);
                },
              ),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsetsGeometry.only(left: 20, right: 10),
      child: ListView(children: items),
    );
  }
}
