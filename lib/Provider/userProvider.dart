import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class UserProvider extends ChangeNotifier {
  User user;
  bool issignedIn = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  void registerUserChange() {
    auth.authStateChanges().listen((User user1) {
      if (user1 != null) {
        issignedIn = true;
        user = user1;

        print("user");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(user.uid)
            .get()
            .then((value) async {
          if (!value.exists) {
            //FirebaseFirestore.instance.collection("Users").doc(user.uid).set()
          }
        });
      } else {
        issignedIn = false;
      }

      notifyListeners();
    });
  }
}
