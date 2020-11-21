import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Home extends StatefulWidget {
  User user;
  Home(this.user);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              onTap: ()async {
                await FirebaseAuth.instance.signOut();
              },
              title: Text("Sign out"),
            )
          ],
        ),
      ),
      appBar: AppBar(

      ),
    );
  }
}