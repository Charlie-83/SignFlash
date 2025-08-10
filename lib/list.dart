import 'package:bslflash/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class WordListPage extends StatefulWidget {
  final void Function(int?) setEdit;
  const WordListPage({super.key, required this.setEdit});

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
    var db = context.watch<Database>();
    return FutureBuilder(
      future: db.words(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<int, String>> wordsAsync) {
            if (!wordsAsync.hasData) {
              return Container();
            }
            final words = wordsAsync.data!;
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
                      widget.setEdit(null);
                    },
                  ),
                ],
              ),
            );

            for (int id in words.keys) {
              final String w = words[id]!;
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
                          widget.setEdit(id);
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
          },
    );
  }
}
