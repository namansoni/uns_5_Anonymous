import 'package:accidentreporter/Screens/Contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../Provider/userProvider.dart';

class OnBoardForm extends StatefulWidget {
  @override
  _OnBoardFormState createState() => _OnBoardFormState();
}

class _OnBoardFormState extends State<OnBoardForm> {
  final _formKey = GlobalKey<FormState>();
  bool showSave = false;
  String name = '';
  String address = '';
  String vehicleNumber = '';
  UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OnBoarding',
          style: TextStyle(color: Colors.orangeAccent[700], fontSize: 30),
        ),
        centerTitle: true,
        leading: Container(),
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: showSave
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _floatButtonAction(userProvider,
                    name: name, address: address, vehicleNumber: vehicleNumber);
              },
              icon: Icon(Icons.save),
              label: Text('Save'),
            )
          : null,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      //controller: name,
                      initialValue: userProvider.userModel.name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        print(val);
                        setState(() {
                          name = val;
                          showSave = true;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      initialValue: userProvider.userModel.address,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          address = val;
                          showSave = true;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      initialValue: userProvider.userModel.vehicleNumber,
                      decoration: InputDecoration(
                        labelText: 'Vehicle License Plate Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (number) {
                        if (number.isEmpty) {
                          return 'Enter License Number';
                        } else if (!RegExp(
                                r'^[A-Z]{2}[ -][0-9]{1,2}(?: [A-Z])?(?: [A-Z]{2})? [0-9]{4}$')
                            .hasMatch(number)) {
                          return 'Enter Valid Number';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          vehicleNumber = val;
                          showSave = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  emergencyContactList(
                    userProvider,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _floatButtonAction(UserProvider userProvider,
      {String name, String address, String vehicleNumber}) async {
    if (_formKey.currentState.validate()) {
      print('uid -${userProvider.user.uid}');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userProvider.user.uid)
          .set({
        'name': name == '' ? userProvider.userModel.name : name,
        'address': address == '' ? userProvider.userModel.address : address,
        'vehicleNumber': vehicleNumber == ''
            ? userProvider.userModel.vehicleNumber
            : vehicleNumber,
      }, SetOptions(merge: true));
      await userProvider.updateDetails();
      Navigator.pop(context);
    }
  }

  Widget emergencyContactList(UserProvider userProvider) {
    List contacts = userProvider.emergencyContacts;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(contacts.length + 2, (index) {
                if (index == 0) {
                  return Text(
                    'Emergency Contacts',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.justify,
                  );
                }
                if (index == contacts.length + 1) {
                  return Padding(
                    padding: EdgeInsets.only(left: 15, top: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactForm()));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add Contact',
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    width: MediaQuery.of(context).size.width - 70,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contacts[index - 1]['name'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(contacts[index - 1]['relation'],
                            style: TextStyle(fontSize: 18)),
                        Text(contacts[index - 1]['phone'],
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                );
              }))),
    );
  }
}
