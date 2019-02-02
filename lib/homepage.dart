import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  final WebSocketChannel channel;

  HomePage({Key key, @required this.channel}): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel("xyz.trankvila.menteiakunulo/audioplayer");

  TextEditingController _controller = TextEditingController();
  List<_Message> history = <_Message>[
    _Message(message: 'test', fromMenteia: true),
    _Message(message: 'test2', fromMenteia: false),
  ];

  @override
  void initState() {
    super.initState();
    widget.channel.stream.listen((data) {
      if (data is String) {
        setState(() {
          history.add(_Message(message: data, fromMenteia: true));
        });
      } else if (data is List<int>) {
        try {
          platform.invokeMethod('playAudio', data);
        } on PlatformException catch (e) {
          debugPrint(e.message);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menteia kunulo"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("Menteia kunulo"),
            ),
            ListTile(
              title: Text('revinas'),
            ),
            ListTile(
              title: Text('girisa'),
            ),
            ListTile(
              title: Text('sasara'),
            ),
            ListTile(
              title: Text('prilema'),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            buildInput(),
            buildChatHistory(),
          ],
        )
      )
    );
  }

  Widget buildInput() {
    return Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'doni/keli ...',
                hintStyle: TextStyle(color: Colors.black26)
              ),
              autofocus: true,
            )
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(icon: Icon(Icons.send), onPressed: () {
                final text = _controller.text;
                widget.channel.sink.add(text);
                setState(() {
                  history.add(_Message(message: text, fromMenteia: false));
                });
                _controller.clear();
              }),
            ),
          )
        ],
      );
  }

  Widget buildChatHistory() {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final message = history[history.length - index - 1];
          return Row(
            children: <Widget>[
              Container(
                child: Text(
                  message.message,
                  style: TextStyle(color: message.fromMenteia ? Colors.white : Colors.black),
                ),
                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                width: 270.0,
                decoration: BoxDecoration(
                    color: message.fromMenteia ? Colors.deepPurple : Colors.black12,
                    borderRadius: BorderRadius.circular(8.0)
                ),
                margin: message.fromMenteia ?
                  EdgeInsets.only(bottom: 10.0, right: 10.0) :
                    EdgeInsets.only(bottom: 10.0, left: 10.0)
              )
            ],
            mainAxisAlignment: message.fromMenteia ? MainAxisAlignment.start : MainAxisAlignment.end,
          );
        },
      )
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}

class _Message {
  _Message({this.message, this.fromMenteia});

  final String message;
  final bool fromMenteia;
}