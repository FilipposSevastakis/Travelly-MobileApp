import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'camera.dart';

import '../consts/pin.dart';

class InitializeTripWidget extends StatefulWidget {
  const InitializeTripWidget(
      {Key? key, required this.data, required this.camera})
      : super(key: key);
  final LatLng data;
  final CameraDescription camera;

  @override
  _InitializeTripWidgetState createState() => _InitializeTripWidgetState();
}

class _InitializeTripWidgetState extends State<InitializeTripWidget> {
  /// Variable that allows data validation
  final _formkey = GlobalKey<FormState>();

  /// Initialization of controllers variables for data extraction from titles field
  final _titleController = TextEditingController();

  List<XFile> ImagePaths = [];

  @override
  void dispose() {
    /// Disposal of resources bound by [TextEditingController]
    _titleController.dispose();
    super.dispose();
  }

  void Gallery_Photos() async {
    List<XFile>? files;
    files = await ImagePicker().pickMultiImage(/*source: ImageSource.gallery*/);
    if (files != null) {
      ImagePaths.addAll(files);
    }
    print(files.length);
    setState(() {});
  }

  void Camera_Photos() async {
    XFile? camImage = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CameraScreenWidget(camera: widget.camera)));
    if (camImage != null) {
      ImagePaths.add(camImage);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar with apps title and delete and save trip buttons
      appBar: AppBar(
          title: const Center(child: Text("Travelly")),
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  final pin = Pin(
                      coord: widget.data,
                      title: _titleController.text,
                      images: ImagePaths);
                  Navigator.pop(context, pin);
                }
              },
            )
          ]),

      /// Body of InitializeTrip (titles text field, buttons for gallery and camera and dynamic photos list)
      body: Form(
          key: _formkey,
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "Title",
                      ),
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title cannot be empty!';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.extended(
                          heroTag:
                              "btn1", // χωρίς αυτό: EXCEPTION CAUGHT BY SCHEDULER LIBRARY
                          label: const Text('Take pic'),

                          icon: const Icon(
                            Icons.camera_alt,
                            size: 24.0,
                          ),
                          onPressed: () {
                            Camera_Photos();
                          },
                        ),
                        FloatingActionButton.extended(
                          heroTag:
                              "btn2", // χωρίς αυτό: EXCEPTION CAUGHT BY SCHEDULER LIBRARY
                          label: const Text('Gallery'),
                          icon: const Icon(
                            Icons.add_outlined,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            Gallery_Photos();
                          },
                        )
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.all(24),
                    child: Container(
                        height: 200,
                        child: Card(
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                              for (var Path in ImagePaths)
                                Card(
                                    child: Container(
                                        width: 180,
                                        height: 26,
                                        child: Image.file(File(Path.path))))
                            ]))))
              ]))),

      /// BottomAppBar with 'Profile', 'Home and 'Messages' buttons
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(CupertinoIcons.person_alt_circle),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home_outlined),
              onPressed: () {},
            ),
            IconButton(
              tooltip: 'Messages',
              icon: const Icon(CupertinoIcons.chat_bubble_2),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
