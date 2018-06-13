import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final url =
      'https://api.stackexchange.com/2.2/questions?order=desc&sort=activity&tagged=flutter&site=stackoverflow';
  final controller = StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    refreshQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // TODO: (not all material) pull into above widget.
        title: 'StackOverflow Viewer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: Column(children: [
          StackOverflowContent(controller.stream),
          PlatformAdaptiveButton(
              child: const Text('Refresh Questions'),
              icon: const Icon(Icons.refresh),
              onPressed: refreshQuestions)
        ])));
  }

  void refreshQuestions() async {
    var result = await http.get(url);
    Map decoded = json.decode(result.body);
    List items = decoded['items'];
    controller.add(items.map<String>((item) => item['title']).toList());
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
  }
}

class StackOverflowContent extends StatelessWidget {
  final Stream<List<String>> questionStream;

  StackOverflowContent(this.questionStream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: questionStream,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasError)
            return Text('Error ${snapshot.error}');
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Receiving questions...');
          }
          return Expanded(
              child: ListView(
                  children: snapshot.data
                      .map<Widget>(
                          (question) => ListTile(title: Text(question)))
                      .toList()));
        });
  }
}

/*class StackOverflow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: http.get(url),
      builder:
    );
    return Scaffold(
      appBar: PlatformAdaptiveAppBar(),
      body:
    );
  }

}*/

class PlatformAdaptiveButton extends StatelessWidget {
  PlatformAdaptiveButton({Key key, this.child, this.icon, this.onPressed})
      : super(key: key);
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoButton(
        child: child,
        onPressed: onPressed,
      );
    } else {
      return IconButton(
        icon: icon,
        onPressed: onPressed,
      );
    }
  }
}
