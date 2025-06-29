import 'package:flutter/material.dart';

class EditPage extends StatelessWidget {
  final String word;
  final void Function(String) cb;
  const EditPage({super.key, required this.word, required this.cb});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: word);
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 10,
          child: FloatingActionButton.small(
            child: Icon(Icons.delete),
            onPressed: () {
              cb("");
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
                  onPressed: () {
                    cb(controller.text);
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
