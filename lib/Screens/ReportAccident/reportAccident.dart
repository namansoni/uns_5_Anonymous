import 'dart:io';

import 'package:accidentreporter/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportAccident extends StatefulWidget {
  @override
  _ReportAccidentState createState() => _ReportAccidentState();
}

class _ReportAccidentState extends State<ReportAccident> {
  PickedFile pickedFile, pickedAccidentFile;
  TextEditingController carNumberConttroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Report an Accident"),
      ),
      body: Container(
        width: width,
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: width * 0.8,
              child: TextFormField(
                controller: carNumberConttroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Enter car number"),
              ),
            ),
            Text("OR"),
            pickedFile == null
                ? OutlineButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      pickedFile =
                          await picker.getImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {});
                      }
                    },
                    child: Text("Upload car number plate image"),
                  )
                : Column(
                    children: [
                      Container(
                        child: Image.file(
                          new File(pickedFile.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text("Uploaded number plate image"),
                      OutlineButton(
                          onPressed: () {
                            setState(() {
                              pickedFile = null;
                            });
                          },
                          child: Text("Cancel"))
                    ],
                  ),
            pickedAccidentFile == null
                ? OutlineButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      pickedAccidentFile =
                          await picker.getImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {});
                      }
                    },
                    child: Text("Upload Accident Image"),
                  )
                : Column(
                    children: [
                      Container(
                        child: Image.file(
                          new File(pickedAccidentFile.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text("Uploaded Accident Image"),
                      OutlineButton(
                          onPressed: () {
                            setState(() {
                              pickedAccidentFile = null;
                            });
                          },
                          child: Text("Cancel"))
                    ],
                  ),
            RaisedButton(
                onPressed: (pickedFile != null && pickedAccidentFile != null)
                    ? () {}
                    : null,
                splashColor: Colors.blue,
                elevation: 6.0,
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: Text("Submit Report",style: buttonText,))
          ],
        ),
      ),
    );
  }
}
