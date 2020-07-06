import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //private variabe, being used all over the class
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
        (FirebaseUser user) => user
            ?.uid, //there maynot be a uid to return if the user isn't logged in, thus the question mark
      ); //tells us if user changes his login state
  //email password sign up
  Future<String> createUserwithEmailandPassword(
      String email, String password, String name) async {
    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    //Note that in the line above the function used is in built in firebase_auth, not the one we created
    //we are using the same name as that function. This makes the call at the higher level look more intuitive

    //update username
    var userUpdateInfo =
        UserUpdateInfo(); //an instance of a firebase_auth class
    userUpdateInfo.displayName =
        name; //uses the above instance to make this update object
    //and now this object knows what to update and with what value
    await currentUser.user.updateProfile(userUpdateInfo);
    await currentUser.user.reload();
    return currentUser.user.uid;
  }

  //email password sign in
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user
        .uid;
  }

//sign out
  signOut() {
    return _firebaseAuth.signOut();
  }

  //reset password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

class EmailValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty';
    } else
      return null;
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 2) {
      return 'Name has to be more than 2 characters';
    }
    if (value.length > 50) {
      return 'Name has to be less than 50 characters';
    }

    return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    } else
      return null;
  }
}
