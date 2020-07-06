import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_authentication/widgets/customDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final primaryColor = Colors.blueAccent.shade200;

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context)
        .size
        .width; //The leading _ makes this a private variable usable only
    final _height = MediaQuery.of(context).size.height; //inside this widget

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('WELCOME!'),
        backgroundColor: Colors.indigoAccent.shade100,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: _width,
          height: _height,
          color: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: _height * 0.1,
                ),
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: _width * 0.1,
                  ),
                  radius: _width * 0.1,
                ),
                SizedBox(
                  height: _height * 0.1,
                ), //as a percentage
                AutoSizeText(
                  'Welcome to the Login Screen User!',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: _height * 0.1,
                ),
                RaisedButton(
                  //for signing up new users
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                          fontSize: 35.0, fontWeight: FontWeight.w300),
                    ),
                  ),
                  textColor: Colors.indigo,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CustomDialog(
                        title: 'Proceed to make a free account!',
                        description:
                            'With a account you can sell and buy books as you please and even contact buyers and sellers',
                        primaryButtonText: 'Create My Account',
                        primaryButtonRoute: '/signUp',
                        secondaryButtonText: 'Maybe Later',
                        secondaryButtonRoute: '/home',
                      ),
                    );
                  },
                ),
                SizedBox(height: _height * 0.05),
                FlatButton(
                  //for sign in
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 28.0, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/signIn');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
