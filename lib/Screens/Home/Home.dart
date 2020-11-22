import 'dart:io';

import 'package:accidentreporter/Models/userModel.dart';
import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:accidentreporter/Screens/Home/HospitalPage.dart';
import 'package:accidentreporter/Screens/onboading.dart';
import 'package:accidentreporter/Screens/ReportAccident/reportAccident.dart';
import 'package:accidentreporter/main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';
import '../onboading.dart';

class Home extends StatefulWidget {
  UserModel userModel;
  User user;
  Home(this.userModel, this.user);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callMethodChannels();
    getToken();
  }

  void callMethodChannels() async {
    MethodChannel channel = MethodChannel("Model");
    if (userType == "user") {
      print(widget.user.uid);
      await channel.invokeMethod("startLocation", {"uid": widget.user.uid});
    } else {
      final pincode = await channel.invokeMethod("getpincode");
      if (pincode != null) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.user.uid)
            .set({'pincode': pincode}, SetOptions(merge: true));
      }
    }

  }
  void getToken(){
    FirebaseMessaging messaging=FirebaseMessaging();
    messaging.getToken().then((value){
      FirebaseFirestore.instance.collection("Users")
            .doc(widget.user.uid)
            .set({'androidNotificationToken': value}, SetOptions(merge: true));
    });
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.user.uid)
          .get(),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }  
        return Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                ListTile(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  title: Text("Sign out"),
                )
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(snapshot.data.data()['userType'] == "user"
                ? "User"
                : "Hospital"),
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (ctx) => OnBoardForm()));
                },
              ),
            ],
          ),
          body: snapshot.data.data()['userType'] == "user"
              ? Container(
                  width: width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ReportAccident()));
                        },
                        splashColor: Colors.blue,
                        elevation: 6.0,
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          "Report an Accident",
                          style: buttonText,
                        ),
                      ),
                    ],
                  ))
              : HospitalPage(),
        );
      },
    );
  }
}
