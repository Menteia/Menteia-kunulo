import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:menteia_kunulo/values.dart';

class TimerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Future<List<Timer>> list;

  @override
  void initState() {
    super.initState();
    list = _fetchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sanimis"),
      ),
      body: Center(
        child: FutureBuilder<List<Timer>>(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1), (i) => i),
                builder: (context, _) {
                  return ListView.builder(itemBuilder: (context, index) {
                    if (index >= snapshot.data.length) {
                      return null;
                    }
                    final entry = snapshot.data[index];
                    final difference = entry.expiration.difference(DateTime.now());
                    final hours = difference.inHours;
                    final minutes = difference.inMinutes.remainder(60);
                    final seconds = difference.inSeconds.remainder(60);
                    final duration = "${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}";
                    return ListTile(
                      title: Text(difference.isNegative ? "00:00:00" : duration),
                      subtitle: Text(entry.name),
                    );
                  });
                },
              );
            } else {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
              }
              return CircularProgressIndicator();
            }
          },
          future: list,
        ),
      ),
    );
  }

  Future<List<Timer>> _fetchList() async {
    final user = await FirebaseAuth.instance.currentUser();
    final token = await user.getIdToken();
    final response = await get(
      "$httpURL/sanimis?token=$token"
    );
    final parsed = json.decode(response.body);
    final list = parsed.map((timer) {
      return Timer.fromJSON(timer);
    }).toList(growable: false).cast<Timer>();
    return list;
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

class Timer {
  final String name;
  final DateTime expiration;

  Timer({this.name, this.expiration});

  static Timer fromJSON(dynamic json) {
    debugPrint(json.toString());
    return Timer(
      name: json['_nomo'],
      expiration: DateTime.parse(json['_fino'])
    );
  }
}