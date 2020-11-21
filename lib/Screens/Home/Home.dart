import 'dart:io';

import 'package:accidentreporter/Models/userModel.dart';
import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:accidentreporter/Screens/ReportAccident/reportAccident.dart';
import 'package:accidentreporter/main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';

class Home extends StatefulWidget {
  UserModel userModel;
  Home(this.userModel);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final width = MediaQuery.of(context).size.width;
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
        title: Text(userType == "user" ? "User" : "Hospital"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: userType == "user"
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
          : Container(
              child: Text("hospital" + userProvider.user.uid.toString()),
            ),
    );
  }
}
