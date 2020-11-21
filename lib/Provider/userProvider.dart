import 'package:accidentreporter/Models/userModel.dart';
import 'package:accidentreporter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class UserProvider extends ChangeNotifier {
  User user;
  bool issignedIn = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel userModel=UserModel();
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
            
            isFirstTime=true;
            print("First time"+isFirstTime.toString());
            FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
              'uid': user.uid,
              'phoneno': user.phoneNumber,
              'userType': userType
            });
            UserModel userModel1=UserModel(
                phoneNumber: user.phoneNumber,
                uid: user.uid,
                userType: userType);
            userModel=userModel1;
            
          } else {
            print("value exists");
            print(value.data()['userType']);
            userType=value.data()['userType'];
            UserModel userModel1=UserModel(
              phoneNumber: user.phoneNumber,
              uid: user.uid,
              userType: value.data()['userType']
            );
            userModel=userModel1;
            print(userModel.phoneNumber);
            print(userModel.uid);
            print(userModel.userType);
          }
        });
      } else {
        issignedIn = false;
      }

      notifyListeners();
    });
  }
}
