import 'dart:io';

import 'package:accidentreporter/styles.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ReportAccident extends StatefulWidget {
  @override
  _ReportAccidentState createState() => _ReportAccidentState();
}

class _ReportAccidentState extends State<ReportAccident> {
  PickedFile pickedFile, pickedAccidentFile;
  TextEditingController carNumberConttroller = TextEditingController();
  List outputs;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Report an Accident"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
              child: Container(
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
              Container(
                width: width * 0.8,
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]),
                    borderRadius: BorderRadius.circular(10)),
                child: pickedFile == null
                    ? OutlineButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
              ),
              SizedBox(height:5),
              Container(
                width: width*0.8,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[400]
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: pickedAccidentFile == null
                    ? OutlineButton(
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RaisedButton(
                      onPressed:
                          (pickedFile != null && pickedAccidentFile != null)
                              ? () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  MethodChannel channel = MethodChannel("Model");
                                  String text = await channel.invokeMethod(
                                      "startModel",
                                      {"imagePath": pickedAccidentFile.path});
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (text != null) {
                                    if (text == "noncar") {
                                      AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.ERROR,
                                          title: "Image is not genuine",
                                          body: Text("Image is not genuine"))
                                        ..show();
                                    }
                                    if (text == "car") {
                                      AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.SUCCES,
                                          title: "Image is genuine",
                                          body: Text("Image is genuine"))
                                        ..show();
                                    }
                                  }
                                }
                              : null,
                      splashColor: Colors.blue,
                      elevation: 6.0,
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        "Submit Report",
                        style: buttonText,
                      ))
            ],
          ),
        ),
      ),
    );
  }
}
