import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:flag/flag.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:username_gen/username_gen.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../consts/user.dart';
import '../Logics/functions.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key, required this.data}) : super(key: key);

  /// list of the coordinations of all pins
  final List data;

  @override
  Profile_screen_State createState() => Profile_screen_State();
}

class Profile_screen_State extends State<Profile_screen> {
  String? imagePath;
  List<Widget> _flags = [];

  final _auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  int index = 0;

  final _formkey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: NewUsername());
    _descriptionController = TextEditingController(text: user.description);
    toFlags(widget.data);
  }

  bool bios_fla = false; // for tick in textfield Bios

  @override
  void dispose() {
    /// Απελευθέρωση των πόρων που δέσμευσαν οι [TextEditingController]
    _descriptionController.dispose();
    _usernameController.dispose();

    /// Τέλος, καλούμε την dispose της υπερκλάσης
    super.dispose();
  }

  void toFlags(coordList) async {
    List isoCodes = [];
    for (var coord in coordList) {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(coord.latitude, coord.longitude);
      isoCodes.add("${placemarks[0].isoCountryCode}");
    }
    List uniqueIsoCodes = isoCodes.toSet().toList();

    List<Widget> flags = [];
    for (var code in uniqueIsoCodes) {
      flags.add(Flag.fromString(code,
          height: 26, width: 50, fit: BoxFit.fill, replacement: Text('404')));
    }

    setState(() {
      _flags = flags;
    });
  }

  String NewUsername() {
    final User = _auth.currentUser;

    if (_auth.currentUser!.displayName != null) {
      user.username = _auth.currentUser!.displayName!;
    } else {
      user.username = UsernameGen().generate();
    }
    return user.username; //_usernameController.text = user.username;
  }

  String? ImagePath() {
    final User = _auth.currentUser;

    if (_auth.currentUser!.photoURL != null) {
      user.photo = _auth.currentUser!.photoURL!;
    } else {
      user.photo = imagePath;
    }
    return user.photo;
    //user.photo; //imagePath;
  }

  // here for change username
  void _editUser() async {
    bool? _edit = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            key: _formkey,
            content: Row(
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context, false);
                    }),
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.check_rounded, color: Colors.black),
                    onPressed: () {
                      //if (_formkey.currentState!.validate()) {
                      Navigator.pop(context, true);
                      // }
                    }),
              ],
            )));
    if (_edit == true) {
      user.username = _usernameController.text;
      final User = _auth.currentUser;
      User!.updateDisplayName(user.username);
      setState(() {});
    }
  }

  // Here open a window with camera and Gallery
  Widget BottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: <Widget>[
            Text("Change Profile photo", style: TextStyle(fontSize: 20)),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  tooltip: "Camera",
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                ),
                IconButton(
                  tooltip: "Gallery",
                  icon: Icon(Icons.image),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                ),
              ],
            )
          ],
        ));
  }

// with function takePhoto we take the photo path(from Gallery or Camera) and save it in string ImagePath
  void takePhoto(ImageSource source) async {
    XFile? file;
    file = await ImagePicker().pickImage(source: source);
    if (file != null) {
      imagePath = file.path;
      final Image_1 = _auth.currentUser;
      Image_1!.updatePhotoURL(imagePath);
    }
    setState(() {}); //ξαναφέρνει το widget ώστε να έχει την νεα εικόνα
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        /// AppBar with  title("Profile") and back (<--) Icon
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              //Εδώ  ορίζουμε ως εικονίδιο στο Appbar το"βελάκι" πουμας γυρίζει πίσω
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context); // Εδώ γυρνάμε τ
              },
            ),

            /// Τίτλος της κεντρικής οθόνης της εφαρμογής μας
            title: Text("Profile")),
        body: Form(
            child: Center(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Column(
                  ///  Στοίχιση πάνω αριστερά στο [body] του [Scaffold]
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: ((builder) => BottomSheet()),
                            );
                          },
                          icon: (ImagePath() != null)
                              ? Image.file(File(ImagePath()!))
                              : Icon(
                                  Icons.person), //asset('images/profile.png'),
                          iconSize: 50,
                          tooltip: "Photo Profile",
                          //here add code  --> here change icon
                        ),
                        //                   SizedBox(
                        //                   width: 10,
                        //               ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                    _usernameController
                                        .text, //widget.data.username,
                                    style: TextStyle(fontSize: 24)),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 16,
                                  ),
                                  onPressed: () =>
                                      _editUser(), // call  function
                                ),
                              ],
                            ),
                            Text("@tag",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Card(
                      child: TextFormField(
                        onTap: () {
                          setState(() {
                            bios_fla = true;
                          });
                        },
                        minLines: 5,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Bio',
                          //       border: OutlineInputBorder(
                          //             borderSide: BorderSide())
                        ),
                        controller: _descriptionController,
                      ),
                    ),
                    Visibility(
                        visible: bios_fla,
                        child: IconButton(
                          icon: Icon(Icons.check_box),
                          onPressed: () {
                            user = Profile(
                              description: _descriptionController.text.isEmpty
                                  ? null
                                  : _descriptionController.text,
                              username: user.username,
                              photo: ImagePath(),
                            );
                            setState(() {
                              bios_fla = false;
                            });
                          },
                        )),
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: Container(
                                      height: 200.0,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            //                  SizedBox(height: 50),
                                            Text(
                                              _flags.length.toString(),
                                              style: TextStyle(
                                                  fontFamily: 'RubikGlitch',
                                                  fontSize: 50,
                                                  color: Colors.black),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text("Countries Visited"),
                                          ]),
                                    ))),
                            SizedBox(width: 16.0),
                            Expanded(
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: Container(
                                        height: 200.0,
                                        child: RadialGauge(
                                            alignment: Alignment.topCenter,
                                            value: _flags.length.toDouble(),
                                            progressBar:
                                                const GaugeRoundedProgressBar(
                                              color: Color(0xFFB4C2F8),
                                            ),
                                            axis: GaugeAxis(
                                              min: 0,
                                              max: 195,
                                              degrees: 240,
                                              style: const GaugeAxisStyle(
                                                thickness: 20,
                                                background: Color(0xFFDFE2EC),
                                              ),
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        RadialGaugeLabel(
                                                            value: _flags.length
                                                                    .toDouble() *
                                                                0.513,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text('%')
                                                      ]),
                                                  Text(
                                                    'of countries visited',
                                                    textAlign: TextAlign.center,
                                                  )
                                                ]))))),
                          ]),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("Collected Flags",
                          style: TextStyle(fontSize: 17)),
                    ),
                    Container(
                        height: 50,
                        child: Card(
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                              for (var flag in _flags) Card(child: flag)
                            ])))
                  ],
                )),
          ),
        )),

        /// BottomBar --> με profile,home,messages
        bottomNavigationBar: BottomNavigationBar(
            //showSelectedLabels: false,
            //showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.person_alt_circle_fill),
                  label: 'Profile'),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: const Icon(CupertinoIcons.chat_bubble_2), label: 'Chat')
            ],
            currentIndex: 1,
            onTap: (int index) {
              switch (index) {
                case 1:
                  Navigator.pop(context);
                  break;
                //  case 2:
              }
            }));
  }
}
