import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'Chat-Home.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
import '../comps/widgets.dart';
import '../comps/styles.dart';
import '../comps/widgets.dart';
import '../consts/pin.dart';

////////////////////////////
class ChatPage extends StatefulWidget {
  final String id;
  final String name;
  ChatPage({Key? key, required this.id, required this.name, required this.data})
      : super(key: key);
  final List<Pin> data;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static messageField({required onSubmit}) {
    final con = TextEditingController();

    return Container(
      margin: const EdgeInsets.all(5),
      child: TextField(
        controller: con,
        decoration: Styles.messageTextFieldStyle(onSubmit: () {
          onSubmit(con);
        }),
      ),
      decoration: Styles.messageFieldCardStyle(),
    );
  }

  var roomId;
  String imageUrl = '';
  String text = '';

  late stt.SpeechToText _speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Scaffold(
      backgroundColor: Colors.indigo.shade400,
      appBar: AppBar(
          leading: IconButton(
            //Εδώ  ορίζουμε ως εικονίδιο στο Appbar το"βελάκι" πουμας γυρίζει πίσω
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context); // Εδώ γυρνάμε τ
            },
          ),
          title: Row(
            children: <Widget>[
              CircleAvatar(
                child: Text(widget.name[0]),
              ),
              SizedBox(width: 10),
              Text(widget.name),
            ],
          ), //Text("@username"), //Εδώ βάζουμε username συνομιλητή
          actions: [
            AvatarGlow(
                animate: isListening,
                glowColor: Colors.teal,
                endRadius: 75,
                duration: const Duration(milliseconds: 2000),
                repeatPauseDuration: const Duration(milliseconds: 100),
                repeat: true,
                child: FloatingActionButton(
                    onPressed: _listen,
                    child: Icon(isListening ? Icons.mic : Icons.mic_none)))
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chats',
                  style: Styles.h1(),
                ),
                const Spacer(),
                StreamBuilder(
                    stream: firestore
                        .collection('Users')
                        .doc(widget.id)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      return !snapshot.hasData
                          ? Container()
                          : Text(
                              'Last seen : ' +
                                  DateFormat('hh:mm a').format(
                                      snapshot.data!['date_time'].toDate()),
                              style: Styles.h1().copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white70),
                            );
                    }),
                const Spacer(),
                const SizedBox(
                  width: 50,
                ),
                IconButton(
                    onPressed: () async {
                      /*
                * Step 1. Pick/Capture an image   (image_picker)
                * Step 2. Upload the image to Firebase storage
                * Step 3. Get the URL of the uploaded image
                * Step 4. Store the image URL inside the corresponding
                *         document of the database.
                * Step 5. Display the image on the list
                *
                * */

                      /*Step 1:Pick image*/
                      //Install image_picker
                      //Import the corresponding library

                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.camera);
                      print('${file?.path}');

                      if (file == null) return;
                      //Import dart:core
                      String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      /*Step 2: Upload to Firebase storage*/
                      //Install firebase_storage
                      //Import the library

                      //Get a reference to storage root
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                          referenceRoot.child('images');

                      //Create a reference for the image to be stored
                      Reference referenceImageToUpload =
                          referenceDirImages.child('name');

                      //Handle errors/success
                      try {
                        //Store the file
                        await referenceImageToUpload.putFile(File(file.path));
                        //Success: get the download URL
                        imageUrl =
                            await referenceImageToUpload.getDownloadURL();
                      } catch (error) {
                        //Some error occurred
                      }
                    },
                    icon: Icon(Icons.camera_alt)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: Styles.friendsBox(),
              child: StreamBuilder(
                  stream: firestore.collection('Rooms').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        List<QueryDocumentSnapshot?> allData = snapshot
                            .data!.docs
                            .where((element) =>
                                element['users'].contains(widget.id) &&
                                element['users'].contains(
                                    FirebaseAuth.instance.currentUser!.uid))
                            .toList();
                        QueryDocumentSnapshot? data =
                            allData.isNotEmpty ? allData.first : null;
                        if (data != null) {
                          roomId = data.id;
                        }
                        return data == null
                            ? Container()
                            : StreamBuilder(
                                stream: data.reference
                                    .collection('messages')
                                    .orderBy('datetime', descending: true)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snap) {
                                  return !snap.hasData
                                      ? Container()
                                      : ListView.builder(
                                          itemCount: snap.data!.docs.length,
                                          reverse: true,
                                          itemBuilder: (context, i) {
                                            return ChatWidgets.messagesCard(
                                                snap.data!.docs[i]['sent_by'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                snap.data!.docs[i]['message'],
                                                DateFormat('hh:mm a').format(
                                                    snap.data!
                                                        .docs[i]['datetime']
                                                        .toDate()));
                                          },
                                        );
                                });
                      } else {
                        return Center(
                          child: Text(
                            'No conversion found',
                            style: Styles.h1()
                                .copyWith(color: Colors.indigo.shade400),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.indigo,
                        ),
                      );
                    }
                  }),
            ),
          ),
          Container(
            color: Colors.white,
            child: ChatWidgets.messageField(onSubmit: (controller) {
              if (controller.text.toString() != '') {
                if (roomId != null) {
                  Map<String, dynamic> data = {
                    'message': controller.text.trim(),
                    'sent_by': FirebaseAuth.instance.currentUser!.uid,
                    'datetime': DateTime.now(),
                  };
                  firestore.collection('Rooms').doc(roomId).update({
                    'last_message_time': DateTime.now(),
                    'last_message': controller.text,
                  });
                  firestore
                      .collection('Rooms')
                      .doc(roomId)
                      .collection('messages')
                      .add(data);
                } else {
                  Map<String, dynamic> data = {
                    'message': controller.text.trim(),
                    'sent_by': FirebaseAuth.instance.currentUser!.uid,
                    'datetime': DateTime.now(),
                  };
                  firestore.collection('Rooms').add({
                    'users': [
                      widget.id,
                      FirebaseAuth.instance.currentUser!.uid,
                    ],
                    'last_message': controller.text,
                    'last_message_time': DateTime.now(),
                  }).then((value) async {
                    value.collection('messages').add(data);
                  });
                }
              }
              controller.clear();
            }),
          )
        ],
      ),
    );
  }

  _listen() async {
    if (!isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'));
      if (available) {
        setState(() => isListening = true);
        _speech.listen(onResult: (val) => text = val.recognizedWords);
      }
    } else {
      print(text);
      setState(() => isListening = false);
      _speech.stop();
      dialog(text);
    }
  }

  void dialog(text) async {
    bool? send = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: _content(text),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Nope')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yep')),
              ],
            ));

//    if (send!) {}
  }

  Widget _content(text) {
    var index = -1;
    for (var pin in widget.data) {
      if (pin.title.toLowerCase() == text.toLowerCase()) {
        index = widget.data.indexOf(pin);
        break;
      }
    }
    if (index == -1) {
      return Text.rich(
          TextSpan(text: 'No pin titled " $text " found', children: []));
    } else {
      Pin foundPin = widget.data.elementAt(index);
      if (foundPin.images == null) {
        return Text.rich(
            TextSpan(text: 'No images found in $text', children: []));
      } else {
        return Container(
            height: 200,
            width: 250,
            child: GridView.count(
                crossAxisCount: 4,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  for (var Path in foundPin.images!)
                    Card(
                        child: Container(
                            width: 26,
                            height: 26,
                            child: Image.file(File(Path.path))))
                ]));
      }
    }
  }
}
