import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../consts/user.dart';

//String mychat_name = user.username;

// we must save user.username in a base or firebase
class Functions {
  static void updateAvailability() {
    final _firestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    //final User = _auth.currentUser;

    //User!.updateDisplayName('ss');

    final data = {
      'name': _auth.currentUser!.displayName ??
          _auth.currentUser!.email, // ?? mychat_name,
      'date_time': DateTime.now(),
      'email': _auth.currentUser!.email,
    };
    try {
      _firestore.collection('Users').doc(_auth.currentUser!.uid).set(data);
    } catch (e) {
      print(e);
    }
  }
}
