import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreenWidget extends StatefulWidget {
  const CameraScreenWidget({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  _CameraScreenWidgetState createState() => _CameraScreenWidgetState();
}

class _CameraScreenWidgetState extends State<CameraScreenWidget> {
  /// Μεταβλητή χειρισμού της κάμερας. Το late υποδηλώνει ότι μπορεί να
  /// αρχικοποιηθεί και μετά τη δημιουργία του στιγμιοτύπου της κλάσης
  late CameraController _controller;

  /// Μεταβλητή για τη αρχικοποίηση του [CameraController]. Περισσότερα στο
  /// σχετικό documentation - https://pub.dev/packages/camera
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    /// Σύνδεση με την κάμερα που έχει έρθει ως παράμετρος στο widget. Επίσης
    /// ορίζουμε ότι η ανάλυση της κάμερας θα είναι μεσαία
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    /// Αρχικοποίηση κάμερας
    _initializeControllerFuture = _controller.initialize();
  }

  /// Καταστροφή στιγμιοτύπου κλάσης
  @override
  void dispose() {
    /// Απελευθέρωση της κάμερας
    _controller.dispose();

    /// Τέλος, καλούμε την dispose της υπερκλάσης
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: Container(
        width: double.infinity,
        height: double.infinity,

        ///  Στοίχιση πάνω αριστερά στο [body] του [Scaffold]
//          crossAxisAlignment: CrossAxisAlignment.start,

        /// Λίστα με τα στοιχεία ([Widget]) της στήλης
//          children: <Widget>[
        /// Εδώ χρειαζόμαστε [FutureBuilder] γιατί η διαθεσιμότητα δεδομένων
        /// από την κάμερα γίνεται ασύγχρτονα
        child: FutureBuilder<void>(

            /// [future] ο αρχικοποιημένος controller της κάμερας
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              /// Όταν γίνει διαθέσιμη η ροή δεδομένων από την κάμερα, δείξε
              /// μια προεπισκόπιση (τι δείχνει η κάμερα)
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                /// Μέχρι να γίνει διαθέσιμη η ροή δεδομένων από την κάμερα
                /// δείξε ένα "κυκλάκι" που γυρίζει
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          try {
            /// Με το που πατηθεί το FAB περιμένουμε μέχρι να γίνει διαθέσιμη
            /// η κάμερα σε εμάς
            await _initializeControllerFuture;

            /// Όταν γίνει διαθέσιμη λαμβάνουμε φωτογραφία, η οποία αποθηκεύεται
            /// προσωρινά στο σύστημα αρχείων του Android
            final camImage = await _controller.takePicture();

            if (!mounted) return;
            Navigator.pop(context, camImage);
          } catch (e) {
            /// Σε περίπτωση σφάλματος, γράφουμε στην debug console το σφάλμα
            /// που εμφανίστηκε
            debugPrint('Error during capture: ${e.toString()}');
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 12,
        highlightElevation: 50,
        child: const Icon(Icons.camera_alt_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
