import 'package:flutter/material.dart';

class EditPage extends StatelessWidget {
  final String word;
  final void Function(String) cb;
  const EditPage({super.key, required this.word, required this.cb});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: word);
    return TextField(
      controller: controller,
      onChanged: (String s) {
        cb(s);
      },
    );
  }
}
