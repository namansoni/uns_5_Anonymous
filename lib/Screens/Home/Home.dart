import 'package:accidentreporter/Models/userModel.dart';
import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:accidentreporter/Screens/onboading.dart';
import 'package:accidentreporter/main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => OnBoardForm()));
            },
          ),
        ],
      ),
      body: userType == "user"
          ? Container(
              child:
                  Text("user" + userProvider.userModel.phoneNumber.toString()),
            )
          : Container(
              child: Text("hospital" + userProvider.userModel.uid.toString()),
            ),
    );
  }
}
