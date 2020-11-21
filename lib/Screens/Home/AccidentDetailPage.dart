import 'package:accidentreporter/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AccidentDetailPage extends StatefulWidget {
  QueryDocumentSnapshot snapshot;
  var pincode;
  AccidentDetailPage(this.snapshot, this.pincode);
  @override
  _AccidentDetailPageState createState() => _AccidentDetailPageState();
}

class _AccidentDetailPageState extends State<AccidentDetailPage> {
  Set<Marker> markers = Set();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers.add(Marker(
      markerId: MarkerId("sdsdsds"),
      position: LatLng(
        widget.snapshot.data()['latitude'],
        widget.snapshot.data()['longitude'],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Accident Details"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.snapshot.data()['accidentImageUrl'],
              width: 200,
              height: 200,
            ),
            Text(widget.snapshot.data()['carNumber']),
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.snapshot.data()['latitude'],
                    widget.snapshot.data()['longitude'],
                  ),
                  zoom: 15,
                ),
                markers: markers,
              ),
            ),
            RaisedButton(
                onPressed: widget.snapshot.data()['isFacilityProvided'] == true
                    ? null
                    : () {
                        FirebaseFirestore.instance
                            .collection("AccidentReports")
                            .doc(widget.pincode)
                            .collection(widget.pincode)
                            .doc(widget.snapshot.data()['carNumber'])
                            .set({'isFacilityProvided': true},
                                SetOptions(merge: true)).then((value){
                                  Navigator.of(context).pop();
                                });
                      },
                splashColor: Colors.blue,
                elevation: 6.0,
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Text("Give Medical Assistance", style: buttonText))
          ],
        ),
      ),
    );
  }
}
