import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final url =
      'https://api.stackexchange.com/2.2/questions?order=desc&sort=activity&tagged=flutter&site=stackoverflow';
  final controller = StreamController<List<StackOverflowInfo>>();

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
        theme: new ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: Scaffold(
            body: Container(
          color: const Color(0xffc0c0c0),
          child: Column(children: [
            CustomAppBar('Stack Overflow TODO'),
            StackOverflowContent(controller.stream),
            PlatformButton(
                child: Text('Refresh'),
                icon: Icon(Icons.refresh),
                onPressed: refreshQuestions)
          ]),
        )));
  }

  void refreshQuestions() async {
    var result = await http.get(url);
    Map decoded = json.decode(result.body);
    List items = decoded['items'];
    controller.add(items
        .where((item) => !item['is_answered'])
        .map<StackOverflowInfo>((item) => StackOverflowInfo.fromJson(item))
        .toList());
  }

  @override
  void dispose() {
    super.dispose();
    controller.close();
  }
}

class CustomAppBar extends StatelessWidget {
  final String title;
  CustomAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return new Container(
      padding: new EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight * 4,
      child: new Center(
        child: new Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Kranky', fontSize: 36.0),
        ),
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: [
            Colors.deepOrange,
            Colors.orangeAccent,
          ],
        ),
      ),
    );
  }
}

class StackOverflowInfo {
  String title;
  int viewCount;
  StackOverflowInfo.fromJson(Map json) {
    title = json['title'];
    viewCount = json['view_count'];
  }
}

class StackOverflowContent extends StatelessWidget {
  final Stream<List<StackOverflowInfo>> questionStream;

  StackOverflowContent(this.questionStream);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: questionStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<StackOverflowInfo>> snapshot) {
          if (snapshot.hasError)
            return Text('Error ${snapshot.error}');
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Receiving questions...');
          }
          return new Expanded(
              child: ListView(
                  children: snapshot.data
                      .map<Widget>((info) => new Card(
                            child: ListTile(
                                title: Text(info.title),
                                leading: new CircleAvatar(
                                  child: new Text(info.viewCount.toString()),
                                )),
                          ))
                      .toList()));
        });
  }
}

class PlatformButton extends StatelessWidget {
  PlatformButton({Key key, this.child, this.icon, this.onPressed})
      : super(key: key);
  final Widget child;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return new CupertinoButton(
        child: child,
        onPressed: onPressed,
      );
    } else {
      return new FloatingActionButton(
        child: icon,
        onPressed: onPressed,
      );
    }
  }
}
