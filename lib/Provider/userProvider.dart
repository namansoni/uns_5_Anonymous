import 'package:accidentreporter/Models/userModel.dart';
import 'package:accidentreporter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../Models/userModel.dart';

class UserProvider extends ChangeNotifier {
  User user;
  bool issignedIn = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel userModel = UserModel();
  List emergencyContacts = [];
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
            isFirstTime = true;
            print("First time" + isFirstTime.toString());
            FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
              'uid': user.uid,
              'phoneno': user.phoneNumber,
              'userType': userType
            }, SetOptions(merge: true));
            UserModel userModel1 = UserModel(
                phoneNumber: user.phoneNumber,
                uid: user.uid,
                userType: userType);
            userModel = userModel1;
          } else {
            print("value exists");
            print(value.data()['userType']);
            userType = value.data()['userType'];
            UserModel userModel1 = UserModel(
              phoneNumber: user.phoneNumber,
              uid: user.uid,
              userType: value.data()['userType'],
              name: value.data()['name'],
              address: value.data()['address'],
              vehicleNumber: value.data()['vehicleNumber'],
            );
            userModel = userModel1;
            emergencyContacts =
                (value.data()['emergencyContacts'] as List) ?? [];
            print(emergencyContacts);
            print(userModel.phoneNumber);
            print(userModel.uid);
            print(userModel.userType);
            print(issignedIn);
          }
        });
      } else {
        issignedIn = false;
      }

      notifyListeners();
    });
  }

  updateContacts() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) => emergencyContacts =
            (value.data()['emergencyContacts'] as List) ?? []);
    notifyListeners();
  }

  updateDetails() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) => userModel = UserModel(
              phoneNumber: user.phoneNumber,
              uid: user.uid,
              userType: value.data()['userType'],
              name: value.data()['name'],
              address: value.data()['address'],
              vehicleNumber: value.data()['vehicleNumber'],
            ));
    notifyListeners();
  }
}
