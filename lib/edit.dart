import 'package:signflash/database.dart';
import 'package:signflash/main.dart';
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
    final db = context.read<Database>();
    final testIdModel = context.read<TestIDModel>();
    return Stack(
      children: [
        id != null
            ? Positioned(
                top: 10,
                right: 10,
                child: FloatingActionButton.small(
                  child: Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Delete"),
                          content: const Text(
                            "Are you sure you want to delete this word?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Yes"),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                            TextButton(
                              child: const Text("No"),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm != null && confirm) {
                      db.deleteRow(id!);
                      testIdModel.update(await db.nextValid(id!));
                      done();
                    }
                  },
                ),
              )
            : SizedBox.shrink(),
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
                    int newId = await context.read<Database>().updateOrAddWord(
                      id,
                      controller.text,
                    );
                    if (testIdModel.testId == null) {
                      testIdModel.update(newId);
                    }
                    done();
                  },
                ),
                FloatingActionButton.small(
                  child: Icon(Icons.cancel),
                  onPressed: () async {
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
