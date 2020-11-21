import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:accidentreporter/Screens/Home/AccidentDetailPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HospitalPage extends StatefulWidget {
  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("Users")
          .doc(userProvider.user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("AccidentReports")
              .doc(snapshot.data.data()['pincode'])
              .collection(snapshot.data.data()['pincode'])
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshots) {
            if (!snapshots.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshots.hasError) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshots.data.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AccidentDetailPage(
                            snapshots.data.docs[index],
                            snapshot.data.data()['pincode'])));
                  },
                  leading: Image.network(
                      snapshots.data.docs[index].data()['accidentImageUrl']),
                  title: Text(snapshots.data.docs[index].data()['carNumber']),
                  subtitle: Text(
                    timeago.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          snapshots.data.docs[index].data()['timestamp']),
                    ),
                  ),
                  trailing:
                      snapshots.data.docs[index].data()['isFacilityProvided'] ==
                              true
                          ? Icon(Icons.check_circle)
                          : Icon(Icons.clear_sharp),
                );
              },
            );
          },
        );
      },
    );
  }
}
