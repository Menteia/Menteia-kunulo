import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:menteia_kunulo/values.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Future<List<String>> lists;

  @override
  void initState() {
    super.initState();
    lists = _fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("girisa"),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
        future: lists,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemBuilder: (context, index) {
                    if (index >= snapshot.data.length) {
                      return null;
                    }
                    final entry = snapshot.data[index];
                    return ListTile(title: Text(entry));
                  }
              );
            } else {
              if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
              }
              return CircularProgressIndicator();
            }
          },
        ),
      )
    );
  }

  Future<List<String>>_fetchLists() async {
    final user = await FirebaseAuth.instance.currentUser();
    final token = await user.getIdToken();
    final response = await get(
      "$httpURL/girisa?token=$token",
    );
    debugPrint(response.body);
    final parsed = json.decode(response.body);
    return parsed.keys.toList(growable: false);
  }
}