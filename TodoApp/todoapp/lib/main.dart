import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:io/io.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(
        title: 'TodoApp',
        items: new List<String>.generate(50, (i) => "Item $i"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  List<String> items;

  MyHomePage({Key key, this.title, @required this.items}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = new ScrollController();
  final TextEditingController _textController = new TextEditingController();
  final Dio dio = new Dio();

  _removeItem(index) {
    widget.items.removeAt(index);
  }

  _sendTimes(text) async {
    await dio.post('http://206.189.124.252:8080/test', data: text);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new FlatButton(
            child: new Text(widget.title,
                style: new TextStyle(
                  fontSize: 20.0,
                  //fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            onPressed: () {
              _scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            }),
        // new Text(widget.title),
        // actions: <Widget>[
        //   new IconButton(
        //     icon: new Icon(Icons.expand_less),
        //     onPressed: () {
        //   _scrollController.animateTo(
        //     0.0,
        //     curve: Curves.easeOut,
        //     duration: const Duration(milliseconds: 300),
        //   );
        // })
        // ],
      ),
      body: new ListView(
        reverse: true,
        children: <Widget>[
          new Container(
              height: 520.0, //550.0,
              child: new ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return new ListTile(
                    leading: new Text(
                      '${index}.-',
                      style: new TextStyle(fontSize: 14.0),
                    ),
                    title: new Text('${widget.items[index]}'),
                    trailing: new IconButton(
                        icon: new Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          print('Removing item ${index}');
                          setState(() {
                            widget.items.removeAt(index);
                          });
                        }),
                  );
                },
                controller: _scrollController,
              )),
          new ListTile(
            title: new TextField(
              decoration: new InputDecoration(
                hintText: "Enter new todo",
              ),
              controller: _textController,
              maxLength: 20,
            ),
            trailing: new IconButton(
              icon: new Icon(Icons.send),
              onPressed: () {
                print('Item added');
                setState(() {
                  widget.items.add(_textController.text);
                });
                _textController.clear();
                var scrollPosition = _scrollController.position;
                _scrollController.animateTo(
                  scrollPosition.maxScrollExtent + 40,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
                print(widget.items);
              },
            ),
          ),
          new Divider(color: Colors.red),
          new ListTile(
              leading: new IconButton(
                icon: new Icon(Icons.cloud_upload, color: Colors.red),
                onPressed: () {
                  print('Send Pressed');
                  _sendTimes(widget.items);
                },
              ),
              title: new Text(
                'DEBUG',
                style: new TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              trailing: new IconButton(
                icon: new Icon(
                  Icons.autorenew,
                  color: Colors.red,
                ),
                onPressed: () {
                  print('Reload Pressed');
                  setState(() {
                    widget.items =
                        new List<String>.generate(50, (i) => "Item $i");
                  });
                },
              ))
        ].reversed.toList(),
      ),
    );
  }
}
