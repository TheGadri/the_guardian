import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_guardian/controller/constants.dart';
import 'package:the_guardian/screens/screens.dart';

class SignUp extends StatefulWidget {
  static const String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //Switch between SignIn and SignUp Screen Helper
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    users = FirebaseFirestore.instance.collection('users');

    if (FirebaseAuth.instance.currentUser != null)
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user != null) {
          users.where('email', isEqualTo: user.email).get().then((value) {});
        }
      });

    super.initState();
  }

  Future<void> addUser(String uid, String token) async {
    return users.add({
      'email': emailController.text,
      'name': nameController.text,
      'uid': uid,
      'role': 'counsellor',
      'phone': phoneController.text,
      'token': "$token",
    }).then((value) {
      users = FirebaseFirestore.instance.collection('users');
      print("User Added well well");
    }).catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Login' : 'Sign Up',
                      style: textTheme.headline3.copyWith(
                        color: Color(0xFF303030),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        _isLogin ? 'Sign Up' : 'Login',
                        style: textTheme.headline6.copyWith(color: Colors.grey),
                      ),
                      onPressed: () {
                        _isLogin = !_isLogin;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Spacer(),
              Material(
                borderRadius: BorderRadius.circular(10),
                shadowColor: Colors.grey.shade100,
                elevation: 50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: AssetImage(
                        'assets/images/gadri_logo.jpg',
                      ))),
                  alignment: Alignment.topCenter,
                ),
              ),
              Spacer(),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLogin
                        ? SizedBox.shrink()
                        : TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your name';
                              } else
                                return null;
                            },
                            decoration: InputDecoration(labelText: 'Name'),
                          ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your email';
                        }
// This is just a regular expression for email addresses
                        String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                            "\\@" +
                            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                            "(" +
                            "\\." +
                            "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                            ")+";
                        RegExp regExp = new RegExp(p);

                        if (regExp.hasMatch(value)) {
// So, the email is valid
                          return null;
                        }

// The pattern of the email didn't match the regex above.
                        return 'Email is not valid';
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    !_isLogin
                        ? TextFormField(
                            controller: phoneController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Phone number',
                            ),
                            keyboardType: TextInputType.number,
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (input) {
                        if (input.isNotEmpty) {
                          if (input.length < 5)
                            return 'Password is too short';
                          else
                            return null;
                        } else
                          return 'Enter your password';
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                  width: deviceWidth,
                  child: !_isLoading
                      ? CupertinoButton(
                          color: kPrimaryColor,
                          child: Text(_isLogin ? 'LOG IN' : 'REGISTER'),
                          onPressed: () async {
                            String token =
                                await FirebaseMessaging.instance.getToken();
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              if (!_isLogin) {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);

                                  if (userCredential.user != null) {
                                    addUser(userCredential.user.uid, token)
                                        .then((value) {
                                      users
                                          .where('email',
                                              isEqualTo:
                                                  userCredential.user.email)
                                          .get()
                                          .then((value) {
                                        Navigator.pushReplacementNamed(
                                            context, HomePage.id, arguments: {
                                          'user': value.docs.first
                                        });
                                      });
                                    });

//                              Navigator.pushReplacementNamed(
//                                  context, HomePage.id,
//                                  arguments: {'user': value.docs.first});
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (e.code == 'weak-password') {
                                    print('The password provided is too weak.');
                                  } else if (e.code == 'email-already-in-use') {
                                    print(
                                        'The account already exists for that email.');
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);

                                  if (userCredential.user != null) {
                                    addUser(userCredential.user.uid, token)
                                        .then((value) {
                                      users
                                          .where('email',
                                              isEqualTo:
                                                  userCredential.user.email)
                                          .get()
                                          .then((value) {
                                        Navigator.pushReplacementNamed(
                                            context, HomePage.id, arguments: {
                                          'user': value.docs.first
                                        });
                                      });
                                    });
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (e.code == 'user-not-found') {
                                    print('No user found for that email.');
                                  } else if (e.code == 'wrong-password') {
                                    print(
                                        'Wrong password provided for that user.');
                                  }
                                }
                              }
                            }
                          },
                        )
                      : Text(
                          'Loading... Please Wait!',
                          style: textTheme.headline6,
                          textAlign: TextAlign.center,
                        )),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
