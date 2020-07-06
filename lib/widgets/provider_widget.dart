import 'package:firebase_authentication/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Provider extends InheritedWidget {
  //the provider alerts all its children whenever the Auth state changes
  final AuthService auth; //AuthService is the class created by us
  Provider({
    Key key,
    Widget child,
    this.auth,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    //whenever there is a change in the
    //Inherited widget this notification goes to all its children
    return true;
  }

  static Provider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Provider>());
//Basically whenever our Auth state changes(user logs in/out), this provider will notify everyone of its children
}
