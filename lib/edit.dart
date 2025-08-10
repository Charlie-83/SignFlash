import 'package:bslflash/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditPage extends StatelessWidget {
  final int? id;
  final void Function() done;
  const EditPage({super.key, required this.id, required this.done});

  @override
  Widget build(BuildContext context) {
    if (id != null) {
      return FutureBuilder(
        future: context.watch<Database>().word(id!),
        builder: (BuildContext context, AsyncSnapshot<String?> word) {
          if (!word.hasData) {
            return Text("");
          }
          return interface(context, word.data!);
        },
      );
    }
    return interface(context, "");
  }

  Widget interface(BuildContext context, String word) {
    final controller = TextEditingController(text: word);
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton.small(
            child: Icon(Icons.delete),
            onPressed: () {
              done();
            },
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.all(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 30),
                    controller: controller,
                  ),
                ),
                FloatingActionButton.small(
                  child: Icon(Icons.save),
                  onPressed: () async {
                    context.read<Database>().updateOrAddWord(
                      id,
                      controller.text,
                    );
                    done();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
