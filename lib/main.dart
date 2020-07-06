import 'package:firebase_authentication/pages/Home.dart';
import 'package:firebase_authentication/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_authentication/pages/first_view.dart';
import 'package:firebase_authentication/pages/sign_up_view.dart';
import 'package:firebase_authentication/widgets/provider_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      //Provider needs to be at the highest level of our widget tree
      auth:
          AuthService(), //because Provider is an Inherited widget we can use this instance of Auth anywhere
      child: MaterialApp(
        title: 'WELCOME SCREEN',
        debugShowCheckedModeBanner: false,
        home: HomeController(),
        routes: <String, WidgetBuilder>{
          '/signUp': (BuildContext context) => SignUpView(
                authFormType: AuthFormType.signUp,
              ),
          '/signIn': (BuildContext context) => SignUpView(
                authFormType: AuthFormType.signIn,
              ),
          '/home': (BuildContext context) =>
              HomeController(), //if you are signed in then only it takes you home
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  //controls if we have to show the home page or the
  //sign in page, depends on the user being logged in/out. We use the Stream<> defined in
  //services/auth_services to do this.
  @override
  Widget build(BuildContext context) {
    final AuthService auth =
        Provider.of(context).auth; //uses the instance of auth Provider has.
    return StreamBuilder(
      stream: auth.onAuthStateChanged, //Stream of String type
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.active) //if the connection is active
        {
          final bool signedIn =
              snapshot.hasData; //if we do get a return that means we have a uid
          //which implies that the user is signed in
          return signedIn ? Listings() : FirstScreen();
          //if the user is signed in go to the listings() that is the home view
          //if not display the login screen given by FirstView
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
