import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menteia_kunulo/listpage.dart';
import 'package:menteia_kunulo/timerpage.dart';
import 'package:menteia_kunulo/values.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  final String idToken;

  HomePage({Key key, @required this.idToken}): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel("xyz.trankvila.menteiakunulo/audioplayer");

  TextEditingController _controller = TextEditingController();
  List<_Message> history = <_Message>[];
  bool connected = false;
  String token;

  @override
  void initState() {
    super.initState();
    final fm = FirebaseMessaging();
    fm.configure(
      onMessage: (message) {
        final content = message["notification"]["body"];
        final paroloID = message["data"]["paroloID"];
        debugPrint(content);
        debugPrint(paroloID);
        get(
          "$httpURL/paroli?token=$token&id=$paroloID"
        ).then((response) {
          try {
            setState(() {
              history.add(_Message(
                  message: content,
                  fromMenteia: true
              ));
            });
            if (response.statusCode == 200) {
              platform.invokeMethod("playAudio", response.bodyBytes);
            }
          } on PlatformException catch (e) {
            debugPrint(e.message);
          }
        });
      }
    );
    fm.getToken().then((deviceToken) {
      FirebaseAuth.instance.currentUser().then((user) {
        user.getIdToken().then((token) {
          post(
            "$httpURL/sciigi?token=$token",
            body: deviceToken,
          ).then((_) {
            setState(() {
              connected = true;
              this.token = token;
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("revinas"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("Menteia kunulo"),
              decoration: BoxDecoration(gradient: RadialGradient(
                center: Alignment(-1.0, -1.0),
                radius: 0.9,
                colors: <Color>[
                  theme.primaryColor,
                  Colors.transparent
                ],
                stops: <double>[
                  0.3,
                  1.0
                ]
              )),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('revinas'),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('talimis'),
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text('sanimis'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TimerPage();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
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
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
              child: TextField(
                controller: _controller,
                enabled: connected,
                decoration: InputDecoration(
                    hintText: 'doni/keli ...',
                    hintStyle: TextStyle(color: Colors.black26)
                ),
                textInputAction: TextInputAction.send,
                onEditingComplete: () {
                  _sendMessage();
                },
              )
          ),
          Material(
            child: Container(
              margin: EdgeInsets.only(left: 8.0),
              child: IconButton(icon: Icon(Icons.send), onPressed: () {
                _sendMessage();
              }),
            ),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 12.0),
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
                    color: message.fromMenteia ? message.error ? Colors.red : Colors.deepPurple : Colors.black12,
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

  void _sendMessage() {
    final text = _controller.text;
    post(
        "$httpURL/respondi?token=$token",
        body: text
    ).then((response) {
      if (response.statusCode == 400) {
        setState(() {
          history.add(_Message(
              message: response.body,
              fromMenteia: true,
              error: true
          ));
        });
      } else {
        final body = jsonDecode(response.body);
        final content = body["teksto"];
        final paroloID = body["UUID"];
        debugPrint(response.body);
        get(
            "$httpURL/paroli?token=$token&id=$paroloID"
        ).then((response) {
          try {
            setState(() {
              history.add(_Message(
                  message: content,
                  fromMenteia: true
              ));
            });
            if (response.statusCode == 200) {
              platform.invokeMethod("playAudio", response.bodyBytes);
            }
          } on PlatformException catch (e) {
            debugPrint(e.message);
          }
        });
      }
    });
    setState(() {
      history.add(_Message(message: text, fromMenteia: false));
    });
    _controller.clear();
  }
}

class _Message {
  _Message({this.message, this.fromMenteia, this.error = false});

  final String message;
  final bool fromMenteia;
  final bool error;
}