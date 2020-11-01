import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class FlutterHtmlPage extends StatefulWidget {

  @override
  FlutterHtmlState createState() => FlutterHtmlState();
}

class FlutterHtmlState extends State<FlutterHtmlPage> {
  var _result = "";
  dynamic result;

  @override
  void initState() {
    super.initState();
    loadAssests();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("FlutterHtml"),
        ),
        body: Html(
          data: _result,
          //Optional parameters:
          // backgroundColor: Colors.white70,
          onLinkTap: (url) {
            // open url in a webview
          },
          // style: {
          //   "div": Style(
          //     block: Block(
          //       margin: EdgeInsets.all(16),
          //       border: Border.all(width: 6),
          //       backgroundColor: Colors.grey,
          //     ),
          //     textStyle: TextStyle(
          //       color: Colors.red,
          //     ),
          //   ),
          // },
          onImageTap: (src) {
            // Display the image in large form.
          },
        )
      // new Markdown(
      //   controller: ScrollController(),
      //   data: _result,
      //   syntaxHighlighter: new HighLight(),
      //   styleSheet: new MarkdownStyleSheet(
      //     p: new TextStyle(fontSize: 16),
      //     h2: new TextStyle(color: Colors.blue, fontSize: 24),
      //   ),
      //   onTapLink: (url) {
      //     // 获取点击链接，可以使用webview展示
      //     print(url);
      //   },
      // ),
    );
  }

  void loadAssests() async {
    result = await _loadFromAssets();
    print(result);
    setState(() {
      _result = result.toString();
    });
  }

  Future<String> _loadFromAssets() async {
    // String filePath = 'assets/files/Markdown.md';
    String filePath = 'assets/files/html.txt';

    String fileContents = await rootBundle.loadString(filePath);
    return fileContents;
  }
}