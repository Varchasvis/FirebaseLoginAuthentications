import 'package:firebase_authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_authentication/widgets/provider_widget.dart';

final primaryColor = Colors.blueAccent.shade200;
enum AuthFormType { signIn, signUp, reset }

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;

  SignUpView({Key key1, @required this.authFormType}) : super(key: key1);

  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;

  _SignUpViewState({this.authFormType}); //takes it from the above widget
  final formKey = GlobalKey<FormState>(); //unsure about this operation
  String _email, _password, _name, _warning;

  void switchFormState(String state) {
    //this function for when the user accidentally goes into signin/signup when they actually wanted to go to
    //signup/signin and they will be provided a button to switch pages. When they do switch pages this function will update the value of
    //authFormType, bringing up the correct page.
    formKey.currentState.reset();
    if (state == 'signUp') {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    form.save(); //ONLY ON SAVING WILL THE FIELDS like eamil and password be set
    if (form.validate()) {
      form.save();
      return true;
    } else
      return false;
  }

  void submit() async //async as it has to interact with the firestore stuff
  {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth; //CRITICAL TO USE PROVIDER HERE
        //DO NOT INSTANTIATE ANOTHER AuthService() as that would defeat the whole point of a Provider
        if (authFormType == AuthFormType.signIn) {
          String uid = await auth.signInWithEmailAndPassword(_email, _password);
          print('Signed In with ID: $uid');
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (authFormType == AuthFormType.reset) {
          await auth.sendPasswordResetEmail(_email);
          print('Password Reset mail has been sent');
          _warning = 'A password reset link has been sent to $_email';
          setState(() {
            authFormType =
                AuthFormType.signIn; //re routing the user to sign in after this
          }); //password reset link has been sent.
        } else {
          String uid = await auth.createUserwithEmailandPassword(
              _email, _password, _name);
          print('Signed Up with New ID: $uid');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        print(e);
        setState(() {
          _warning = e.message; //Handled by Firebase
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context)
        .size
        .width; //The leading _ makes this a private variable usable only
    final _height = MediaQuery.of(context).size.height; //inside this widget

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //important discovery, centers the text perfectly despite the leading and trailing fields being set
        title: Text('Please Proceed'),
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: primaryColor,
          height: _height,
          width: _width,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: _height * 0.025,
                ),
                showAlert(),
                SizedBox(
                  height: _height * 0.025,
                ),
                buildHeaderText(),
                SizedBox(
                  height: _height * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: buildInputs() + buildButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.error),
            Padding(
              padding: EdgeInsets.only(right: 8.0),
            ),
            Expanded(
                child: AutoSizeText(
              _warning,
              maxLines: 3,
            )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
    return (SizedBox(
      height: 0.0,
    ));
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signIn)
      _headerText = 'Sign In';
    else if (authFormType == AuthFormType.reset)
      _headerText = 'Password Reset';
    else
      _headerText = 'Create New Account';
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = []; //empty list initialization

    if (authFormType == AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: TextStyle(fontSize: 20.0),
          decoration: buildSignUpInputDecoration('Email'),
          onSaved: (newValue) => _email = newValue,
        ),
      );
      textFields.add(
        SizedBox(
          height: 10.0,
        ),
      );
      return textFields;
    }
    //if were in the sign up state, add name
    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 20.0),
          decoration: buildSignUpInputDecoration('Name'),
          onSaved: (newValue) => _name = newValue,
        ),
      );
      textFields.add(
        SizedBox(
          height: 10.0,
        ),
      );
    }
    //add email and password
    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        //the text in the form value is implicitly passed to the validator
        style: TextStyle(fontSize: 20.0),
        decoration: buildSignUpInputDecoration('Email'),
        onSaved: (newValue) => _email = newValue,
      ),
    );
    textFields.add(SizedBox(
      height: 10.0,
    ));
    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        obscureText: true,
        style: TextStyle(fontSize: 20.0),
        decoration: buildSignUpInputDecoration('Password'),
        onSaved: (newValue) => _password = newValue,
      ),
    );
    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 0.0),
      ),
      contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
    );
  }

  List<Widget> buildButtons() {
    bool _showForgotPassword = false;
    String _switchButton, _newFormState, _submitButtonText;
    if (authFormType == AuthFormType.signUp) {
      _switchButton = 'Already have an account? Sign in';
      _newFormState = 'signIn';
      _submitButtonText = 'Sign Up';
    } else if (authFormType == AuthFormType.reset) {
      _switchButton = 'Return to Sign In';
      _newFormState = 'signIn';
      _submitButtonText = 'Submit';
    } else {
      _switchButton = 'Create new account';
      _newFormState =
          'signUp'; //had the String for newFormState been more carefully chosen, we could have done this without the third variable here
      _submitButtonText = 'Sign In';
      _showForgotPassword = true;
    }
    List<Widget> buttonList = [];

    buttonList.add(SizedBox(
      height: 20.0,
    ));
    buttonList.add(Container(
      //The container contains the final submit button, which will add or confirm data with the database
      width: MediaQuery.of(context).size.width * 0.5,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        textColor: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _submitButtonText,
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        onPressed: submit,
      ),
    ));

    buttonList.add(SizedBox(
      height: 20.0,
    ));
    buttonList.add(FlatButton(
      child: AutoSizeText(
        _switchButton,
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
      onPressed: () {
        switchFormState(_newFormState);
      },
    ));
    if (_showForgotPassword) {
      buttonList.add(
        FlatButton(
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              authFormType = AuthFormType.reset;
            });
          },
        ),
      );
    }
    return buttonList;
  }
}
