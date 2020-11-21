import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/userProvider.dart';

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  TextEditingController name = TextEditingController();
  TextEditingController relation = TextEditingController();
  //TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showAdd = false;
  UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Contact',
          style: TextStyle(color: Colors.orangeAccent[700], fontSize: 30),
        ),
        centerTitle: false,
        leading: Container(),
        elevation: 5,
        backgroundColor: Colors.white,
      ),
      floatingActionButton: showAdd
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _floatButtonAction(userProvider);
              },
              icon: Icon(Icons.person_add_alt),
              label: Text('Add'),
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
                      controller: name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          showAdd = true;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: relation,
                      decoration: InputDecoration(
                        labelText: 'Relation',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          showAdd = true;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      controller: phoneNumber,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (number) {
                        if (number.isEmpty) {
                          return 'Enter Phone Number';
                        } else if (number.length == 10 ||
                            (number.length == 13 && number.startsWith('+'))) {
                          if (RegExp(r'[0-9]{10}').hasMatch(number) ||
                              RegExp(r'[0-9]{12}')
                                  .hasMatch(number.substring(1))) {
                            return null;
                          }
                          return 'Enter Valid Number';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          showAdd = true;
                        });
                      },
                    ),
                  ),
                  //emergencyContactList();
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _floatButtonAction(UserProvider userProvider) async {
    if (_formKey.currentState.validate()) {
      print('uid -${userProvider.user.uid}');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userProvider.user.uid)
          .update({
        "emergencyContacts": FieldValue.arrayUnion([
          {
            'name': name.text,
            'relation': relation.text,
            'phone': phoneNumber.text,
          }
        ])
      });
      await userProvider.updateContacts();
      Navigator.pop(context);
    }
  }
}
