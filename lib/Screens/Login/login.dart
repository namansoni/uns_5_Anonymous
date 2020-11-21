import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:accidentreporter/styles.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  bool isLoading = false, iscodeSent = false, issigningIn = false;
  FirebaseAuth auth;
  String _verificationId;
  PersistentBottomSheetController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(206, 253, 255, 1),
      key: scaffoldState,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Container(
                  width: 200,
                  height: 40,
                  child: RaisedButton(
                    splashColor: Colors.blue,
                    
                    elevation: 6.0,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      isLoading = false;
                      iscodeSent = false;
                      issigningIn = false;
                      mobileNumberController.text = "+91";
                      Timer(Duration(
                        milliseconds: 200,
                      ), () {
                        _controller =
                            scaffoldState.currentState.showBottomSheet(
                          (context) => bottomSheet1(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          elevation: 50,
                        );
                      });
                    },
                    child: Text(
                      "Register as User",
                      style: buttonText,
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  height: 40,
                  child: RaisedButton(
                    splashColor: Colors.blue,
                    
                    elevation: 6.0,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    onPressed: () {
                      isLoading = false;
                      iscodeSent = false;
                      issigningIn = false;
                      mobileNumberController.text = "+91";
                      Timer(Duration(
                        milliseconds: 200,
                      ), () {
                        _controller =
                            scaffoldState.currentState.showBottomSheet(
                          (context) => bottomSheet1(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          elevation: 50,
                        );
                      });
                    },
                    child: Text(
                      "Register as Hospital",
                      style: buttonText,
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

  Widget bottomSheet1() {
    return SingleChildScrollView(
      child: Container(
        child: !iscodeSent
            ? Container(
                height: 222,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            "Enter Mobile Number",
                            style: subtitleText,
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: mobileNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: "Mobile Number",
                              labelStyle: TextStyle(color: Colors.blue),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    isLoading
                        ? CircularProgressIndicator()
                        : RaisedButton(
                            onPressed: () {
                              _controller.setState(() {
                                isLoading = true;
                              });
                              loginUser();
                            },
                            elevation: 6.0,
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            child: Text(
                              "Submit",
                              style: buttonText,
                            ),
                          ),
                    SizedBox(height: 40),
                  ],
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: 222,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    FadeIn(
                      child: Text(
                        "Enter OTP",
                        style: subtitleText,
                      ),
                    ),
                    SizedBox(height: 10),
                    FadeIn(
                      child: Container(
                        width: 150,
                        child: TextFormField(
                          onChanged: (value) {},
                          controller: codeController,
                          style: TextStyle(fontSize: 30, letterSpacing: 5),
                          decoration: InputDecoration(
                            hintText: "123456",
                            hintStyle: TextStyle(color: Colors.grey[300]),
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    issigningIn
                        ? CircularProgressIndicator()
                        : FadeIn(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: RaisedButton(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                onPressed: () async {
                                  _controller.setState(() {
                                    issigningIn = true;
                                  });

                                  AuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationId,
                                          smsCode: codeController.text);
                                  UserCredential result;
                                  try {
                                    result = await auth
                                        .signInWithCredential(credential);
                                  } catch (error) {
                                    print("Invalid code");
                                    Flushbar(
                                      title: "Invalid OTP",
                                      messageText: Text(
                                        "Please enter correct OTP!",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                      isDismissible: false,
                                    )..show(context);
                                    _controller.setState(() {
                                      codeController.text = "";
                                      issigningIn = false;
                                    });
                                    return;
                                  }

                                  User user = result.user;
                                  if (user != null) {
                                    _controller.setState(() {
                                      issigningIn = false;
                                    });
                                    Navigator.of(context).pop();
                                    print("Sign in successfully");
                                  } else {
                                    print("sign in error");
                                  }
                                },
                                child: Text(
                                  "Confirm",
                                  style: buttonText,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }

  void loginUser() async {
    auth.verifyPhoneNumber(
      codeAutoRetrievalTimeout: (String value) {
        print(value);
      },
      timeout: Duration(seconds: 3),
      phoneNumber: mobileNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        Navigator.of(context).pop();
        UserCredential userCredential =
            await auth.signInWithCredential(credential);
        User user = userCredential.user;
        if (user != null) {
          print("Logged in successfully");
        } else {
          print("Logged in error");
        }
      },
      verificationFailed: (FirebaseAuthException exception) {

        print(exception);
        _controller.setState(() {
          isLoading = false;
        });

        Flushbar(
          title: "Invalid Phone Number",
          messageText: Text(
            "The phone number provider is incorrect!",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
          isDismissible: false,
        )..show(context);
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        _controller.setState(() {
          iscodeSent = true;
          _verificationId = verificationId;
        });
      },
    );
  }
}
