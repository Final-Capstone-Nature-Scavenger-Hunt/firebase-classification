import 'package:flutter/material.dart';
import 'package:odysee/services/auth.dart';
import 'package:odysee/shared/loading.dart';
import 'package:odysee/shared/styles.dart';


class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String email = '';
  String password = '';
  bool loading = false;
  String error = '';

  final _formkey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
        
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 60.0, horizontal:50.0),
          decoration: Styles.authBackgroundDecoration,

          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                Text("ODYSSEE",
                  style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.brown,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.0),
                TextFormField(
                    decoration: Styles.textInputDecoration.copyWith(hintText: 'Email'),
                    validator: (val) => val.isEmpty ? 'Enter an email': null,
                    onChanged:(val){
                      setState(() => email = val);
                    },
                    ),

                SizedBox(height: 20.0),

                TextFormField(
                    decoration: Styles.textInputDecoration.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (val) => val.length < 6 ? 'Enter a value at least 6 characters long': null,
                    onChanged:(val){
                      setState(() => password = val);
                    },
                  ), 
                
                SizedBox(height: 20.0),

                RaisedButton(
                  color: Colors.teal[300], 
                  child: Text(
                    'Log In',
                    style: TextStyle(color : Colors.white)
                    ),
                  onPressed: () async {
                    if(_formkey.currentState.validate()){
                      setState(() => loading = true);
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);

                      if (result == null){
                        setState(() {
                          error = 'Please supply a valid email and password';
                          loading = false;
                        });
                      }
                    }
                  }, 
                  ),

                SizedBox(height: 10.0),
                
                Text('Don\'t have an account?',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white),
                ),

                SizedBox(height: 10.0),

                RaisedButton(
                  color: Colors.teal[300],
                  child: Text(
                    'Create An Account',
                    style: TextStyle(color: Colors.white)
                  ),
                  onPressed: () async {
                    widget.toggleView();
                  },
                )
                  
              ],
            ),
          )
        )
        );
      }
      }