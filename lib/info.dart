import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final titleStyle = TextStyle(fontSize: 30);
final paragraphStyle = TextStyle(fontSize: 15);
final Uri contactEmailUri = Uri(scheme: "mailto", path: "dev@charlie83.com");
final Uri githubIssuesUri = Uri(
  scheme: "https",
  path: "github.com/Charlie-83/SignFlash/issues",
);

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsGeometry.only(
        top: 10,
        left: 25,
        right: 25,
        bottom: 20,
      ),
      children: [
        Text("Info", style: titleStyle),
        Text(
          "Setting the language to BSL or ASL just changes the website you are taken to when you press the web button from the test screen.\nThe current word is added to the end of the url. If the word contains '/' or '(', everything after and including these symbols isn't put into the url. This is useful to add notes or alternatives to the word. For example, 'Break (in half)' clarifies which kind of break the word is (it isn't the 'Take a break' kind) but it will still link to the word 'break'.\nIf you remember the word, you can press the green tick button and if you forget it and needed to check the video you can press the red cross button. The app tracks whether you got each word correct and will test you more often on words you struggle with.\nYou can import/export words from/to a file. This is just a simple text file with a new word on each line.",
          style: paragraphStyle,
        ),
        SizedBox(height: 20),
        Text("Contact", style: titleStyle),
        Text(
          "You can contact me with bug reports, feature request or anything else via email or via Github issues (requires a Github account).",
          style: paragraphStyle,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            FloatingActionButton.small(
              child: Icon(Icons.email),
              onPressed: () {
                launchUrl(contactEmailUri);
              },
            ),
            SizedBox(width: 15),
            Text("Email (dev@charlie83.com)"),
          ],
        ),
        Row(
          children: [
            FloatingActionButton.small(
              child: Icon(Icons.language),
              onPressed: () {
                launchUrl(githubIssuesUri);
              },
            ),
            SizedBox(width: 15),
            Text("Github"),
          ],
        ),
      ],
    );
  }
}
