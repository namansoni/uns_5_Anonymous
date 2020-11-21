import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:accidentreporter/Screens/FirstTime/hospital.dart';
import 'package:accidentreporter/Screens/FirstTime/user.dart';
import 'package:accidentreporter/Screens/Login/login.dart';
import 'package:accidentreporter/styles.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'Screens/Home/Home.dart';

String userType = "user";
bool isFirstTime=false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: UserProvider(),
        ),
      ],
      child: MaterialApp(home: OnBoarding()),
    );
  }
}

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  bool isDialogOpen = false;
  bool isRegistered = false;
  @override
  void initState() {
    // TODO: implement initState
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        isDialogOpen = true;
        print("listening to bluetooth");
        showDialog1();
      } else {
        if (isDialogOpen) {
          isDialogOpen = false;
          Navigator.of(context).pop();
        }
        print("Bluetooth is on");
      }
    });
    super.initState();
    getPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (!isRegistered) {
      print("listening");
      isRegistered = true;
      userProvider.registerUserChange();
    }
    return userProvider.issignedIn
        ? Home(userProvider.userModel,userProvider.user)
        : Login();
  }

  void getPermissions() async {
    await requestPermission();
  }

  void showDialog1() {
    AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      customHeader: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage("assets/images/bluetooth.png"),
      ),
      body: Column(
        children: [
          Text(
            'Bluetooth is off',
            style: subtitleText,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Bluetooth must be on all the time.",
            style: subtitleTextSmall,
          )
        ],
      ),
    )..show();
  }
}
