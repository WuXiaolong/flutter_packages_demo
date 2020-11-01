import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'my_markdown_style.dart';

class FlutterMarkdownPage extends StatefulWidget {

  @override
  FlutterMarkdownState createState() => FlutterMarkdownState();
}

class FlutterMarkdownState extends State<FlutterMarkdownPage> {
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
          title: Text('FlutterMarkdown'),
        ),
        body:
      new Markdown(
        controller: ScrollController(),
        data: _result,
        syntaxHighlighter: new HighLight(),
        styleSheet: new MarkdownStyleSheet(
          p: new TextStyle(fontSize: 16),
          h2: new TextStyle(color: Colors.blue, fontSize: 24),
        ),
        onTapLink: (url) {
          // 获取点击链接，可以使用webview展示
          print(url);
        },
      ),
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
    String filePath = 'assets/files/Markdown.md';

    String fileContents = await rootBundle.loadString(filePath);
    return fileContents;
  }
}