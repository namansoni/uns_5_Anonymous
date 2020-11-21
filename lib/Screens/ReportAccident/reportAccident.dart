import 'dart:io';

import 'package:accidentreporter/Provider/userProvider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:async';
import 'package:accidentreporter/styles.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as Im;

class ReportAccident extends StatefulWidget {
  @override
  _ReportAccidentState createState() => _ReportAccidentState();
}

class _ReportAccidentState extends State<ReportAccident> {
  PickedFile pickedFile, pickedAccidentFile;
  TextEditingController carNumberConttroller = TextEditingController();
  List outputs;
  bool isLoading = false;
  String carNumber;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
                          _getNumberPlate(pickedFile.path);
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
                            child: Text("Cancel"),
                          )
                        ],
                      ),
              ),
              SizedBox(height: 5),
              Container(
                width: width * 0.8,
                height: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]),
                    borderRadius: BorderRadius.circular(10)),
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
                      onPressed: (carNumberConttroller.text.trim().length >=
                                  13 &&
                              pickedAccidentFile != null)
                          ? () async {
                              setState(() {
                                isLoading = true;
                              });
                              MethodChannel channel = MethodChannel("Model");
                              String text = await channel.invokeMethod(
                                  "startModel",
                                  {"imagePath": pickedAccidentFile.path});

                              if (text != null) {
                                if (text == "noncar") {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      title: "Image is not genuine",
                                      body: Text("Image is not genuine"))
                                    ..show();
                                }
                                if (text == "car") {
                                  createReport(userProvider.user);
                                }
                              } else {}
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

  void createReport(User user) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        String pincode = value.data()['pincode'];
        String adminArea = value.data()['adminArea'];
        String subAdminArea = value.data()['subAdminArea'];
        FirebaseFirestore.instance
            .collection("Locations")
            .doc(adminArea)
            .collection(adminArea)
            .doc(subAdminArea)
            .collection(subAdminArea)
            .doc(pincode)
            .collection(pincode)
            .doc(user.uid)
            .get()
            .then((locationData) async {
          final latitude = locationData.data()['latitude'];
          final longitude = locationData.data()['longitude'];

          File accidentImage =
              await compressImage(new File(pickedAccidentFile.path));
          UploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child("AccidentImage_${carNumberConttroller.text.trim()}")
              .putFile(accidentImage);

          uploadTask.whenComplete(() async {
            String url = await uploadTask.snapshot.ref.getDownloadURL();
            FirebaseFirestore.instance
                .collection("AccidentReports")
                .doc(pincode)
                .collection(pincode)
                .doc(carNumberConttroller.text.trim())
                .set({
              'carNumber': carNumberConttroller.text.trim(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'latitude': latitude,
              'longitude': longitude,
              'accidentImageUrl': url,
              'isFacilityProvided':false
            }).then((value) {
              setState(() {
                isLoading = false;
                carNumberConttroller.text = "";
                pickedFile = null;
                pickedAccidentFile = null;
              });
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.SUCCES,
                  body: Text(
                    "Accident Report has been successfully submited. We have informed the nearby hospitals",
                    textAlign: TextAlign.center,
                  ))
                ..show();
            });
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    final compressedImage =
        File("$path/img_${DateTime.now().millisecondsSinceEpoch}.jpg")
          ..writeAsBytesSync(Im.encodeJpg(image, quality: 80));
    return compressedImage;
  }
  _getNumberPlate(String filePath) async {
    final Completer<Size> completer = Completer<Size>();
    Image _image = Image.file(
      new File(filePath),
    );
    _image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    final File imageFile = File(filePath);

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String pattern =
        r'^[A-Z]{2}[ -][0-9]{1,2}(?: [A-Z])?(?: [A-Z]{2})? [0-9]{4}$';
    RegExp regEx = RegExp(pattern);

    String numberPlate = "";
    List<TextElement> _elements = [];
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        print(line.text);
        if (regEx.hasMatch(line.text)) {
          numberPlate += line.text + '\n';
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
      }
    }

    setState(() {
      carNumber = numberPlate;
      carNumberConttroller.text = carNumber;
    });
    print('carnumber- $carNumber');
  }

}
