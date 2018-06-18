import 'package:flutter/material.dart' show AppBar, BuildContext, Colors, Container, Curves, Divider, FlatButton, GlobalKey, Icon, IconButton, Icons, InputDecoration, Key, ListTile, ListView, MaterialApp, RefreshIndicator, RefreshIndicatorState, Scaffold, ScrollController, State, StatefulWidget, StatelessWidget, Text, TextAlign, TextEditingController, TextField, TextStyle, ThemeData, Widget, required, runApp;
import 'package:flutter/foundation.dart' show Key, required;
import 'package:dio/dio.dart' show Dio;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'dart:async' show Future;
import 'dart:convert' show JsonDecoder;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:core';

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
  final Stopwatch timer = new Stopwatch();
  final Times = {
    'addTodoAverage': 0.00000,
    'removeTodoAverage': 0.00000,
    'loadJSONAverage': 0.00000,
    'getTodosAverage': 0.00000,
    'addTodo': [],
    'removeTodo': [],
    'getTodos': [],
    'loadJSON': [],
  };

  final List<int> addTodoTimes = new List<int>();
  final List<int> removeTodoTimes = new List<int>();
  final List<int> loadJSONTimes = new List<int>();
  final List<int> getTodosTimes = new List<int>();

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
     _loadJSON();
  }

  Future<String> _fetchJSON() async {
    return await rootBundle.loadString('assets/data/MOCK_DATA_100.json');
  }

  Future<Null> _refreshTodos() async {
    timer.start();

    refreshKey.currentState?.show(atTop: false);
    //await Future.delayed(Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    setState(() {
          widget.items = (prefs.getStringList('todos') ?? 0);
    });

    timer.stop();
    getTodosTimes.add(timer.elapsedMicroseconds);
    print(getTodosTimes.length);
    timer.reset();
    
    return null;
  }

  _updateStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', widget.items);
  }

  _loadJSON() async {
    timer.start();

    JsonDecoder decoder = new JsonDecoder();
    String json = await _fetchJSON();
    List dec = decoder.convert(json);

    setState(() {
          widget.items = dec.cast<String>().toList();
    });

    _updateStorage();

    timer.stop();
    loadJSONTimes.add(timer.elapsedMicroseconds);
    print(loadJSONTimes.length);
    timer.reset();

  }

  _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
          widget.items = (prefs.getStringList('todos') ?? 0);
    });
  }

  _removeTodo(index) async {
    timer.start();

    setState(() {
      widget.items.removeAt(index);
    });

    _updateStorage();

    timer.stop();
    removeTodoTimes.add(timer.elapsedMicroseconds);
    print(removeTodoTimes.length);
    timer.reset();
  }

  _addTodo(todo) async{
    timer.start();

    if(todo != ''){
      setState(() {
        widget.items.add(todo);
      });
    }

    _updateStorage();

    _textController.clear();
    var scrollPosition = _scrollController.position;
    _scrollController.animateTo(
      scrollPosition.maxScrollExtent + 40,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );

    timer.stop();
    addTodoTimes.add(timer.elapsedMicroseconds);
    print(addTodoTimes.length);
    timer.reset();
  }

  _sendTimes(text) async {
    var sumAddTodos = 0, sumRemoveTodos = 0, sumLoadJSON = 0, sumGetTodos = 0;
    for(int i = 0; i < 100; i++) {
      sumAddTodos += addTodoTimes[i];
      sumRemoveTodos += removeTodoTimes[i];
      sumLoadJSON += loadJSONTimes[i];
      sumGetTodos += getTodosTimes[i];
    }

    Times['addTodoAverage'] = (sumAddTodos/100)/1000;
    Times['removeTodoAverage'] = (sumRemoveTodos/100)/1000;
    Times['loadJSONAverage'] = (sumLoadJSON/100)/1000;
    Times['getTodosAverage'] = (sumGetTodos/100)/1000;
    Times['addTodo'] = addTodoTimes;
    Times['removeTodo'] = removeTodoTimes;
    Times['getTodos'] = getTodosTimes;
    Times['loadJSON'] = loadJSONTimes;

    print(Times);
    
    await dio.post('http://206.189.124.252:8080/test', data: Times);
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
              child: new RefreshIndicator(
                key: refreshKey,
                onRefresh: _refreshTodos,
                child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return new ListTile(
                    leading: new Text(
                      '${index+1}.-',
                      style: new TextStyle(fontSize: 14.0),
                    ),
                    title: new Text('${widget.items[index]}'),
                    trailing: new IconButton(
                        icon: new Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          print('Removing item ${index}');
                          _removeTodo(index);
                        }),
                  );
                },
                controller: _scrollController,
              )
              )
              ),
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
                _addTodo(_textController.text);
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
                  _loadJSON();
                },
              ))
        ].reversed.toList(),
      ),
    );
  }
}
