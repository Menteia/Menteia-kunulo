import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menteia_kunulo/homepage.dart';

class LoginPage extends StatefulWidget {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loggingIn = false;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        user.getIdToken(refresh: true).then((idToken) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return HomePage(
              idToken: idToken,
            );
          }));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Menteia kunulo",
          textAlign: TextAlign.center,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _emailField(),
              _passwordField(),
              _loginButton(),
            ],
          ),
        ),
      )
    );
  }

  Widget _emailField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 50.0, 0, 0),
      child: TextFormField(
        maxLines: 1,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Retpoŝtadreso",
          icon: Icon(Icons.email)
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 30.0, 0, 0),
      child: TextFormField(
        maxLines: 1,
        controller: _passwordController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
            hintText: "Pasvorto",
            icon: Icon(Icons.lock)
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 30.0, 0, 0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.deepPurple,
          child: Text("Ensaluti", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: _login,
          disabledColor: Colors.grey,
        ),
      ),
    );
  }

  void _login() {
    setState(() {
      loggingIn = true;
    });
    widget.auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text
    ).then((user) async {
      final idToken = await user.getIdToken();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(
          idToken: idToken,
        );
      }));
    }).catchError((error) {
      debugPrint(error);
    });
  }
}