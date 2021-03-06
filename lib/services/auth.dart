import 'package:odysee/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create a user object based on FirebaseUser
  User _userFromFirebase(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream

  Stream<User> get user {
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebase(user));
    .map(_userFromFirebase);
  }

  // sign in anon
  Future signInAnon() async {

    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebase(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebase(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // create a new documetn for the user with the uid
      //await DatabaseService(uid : user.uid).updateUserData('0', 'new crew member', 100);
      return _userFromFirebase(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e){
      print(e.toString());
      return null;
    }
  }
}