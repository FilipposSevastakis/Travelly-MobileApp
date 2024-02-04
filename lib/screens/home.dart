import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:camera/camera.dart';
import 'dart:async';

import '../consts/pin.dart';
import '../services/sqlite.dart';

import '../main.dart';
import 'init.dart';
import 'edit.dart';
import 'profile.dart';
import 'settings.dart';
import 'Chat-Home.dart';
import 'chatpage.dart';

//// 'https://{s}.tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png' HellMode

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  LatLng coord = LatLng(49.5, -0.09);
  List<Pin> _pins = <Pin>[];
  List<Marker> _markers = <Marker>[];
  late CameraController controller;
  late SQLiteService sqLiteService;

  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    sqLiteService = SQLiteService();
    sqLiteService.initDB().whenComplete(() async {
      final pins = await sqLiteService.getPins();
      List<Marker> markers = [];
      if (pins != null) {
        for (var pin in pins) {
          markers.add(_markerFromPin(pin));
        }
      }

      setState(() {
        _pins = pins;
        _markers = markers;
      });
    });

    controller = CameraController(firstCamera, ResolutionPreset.max);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// Καταστροφή στιγμιοτύπου κλάσης
  @override
  void dispose() {
    /// Απελευθέρωση της κάμερας
    controller.dispose();
    _titleController.dispose();

    /// Τέλος, καλούμε την dispose της υπερκλάσης
    super.dispose();
  }

  /// Creates a list from the item.x of each item in initList
  List<LatLng> _onlyCoord(pinList) {
    List<LatLng> onlyCoord = [];
    for (var item in pinList) {
      onlyCoord.add(item.coord);
    }
    return onlyCoord;
  }

  /// Function that returns a Marker from a Pin
  Marker _markerFromPin(pin) {
    var x = Marker(
        width: 80.0,
        height: 80.0,
        point: pin.coord,
        builder: (context) => IconButton(
            icon: const Icon(Icons.location_on_sharp,
                color: Color.fromARGB(255, 155, 16, 6)),
            onPressed: () => _editPin(pin)));

    return x;
  }

  /// Void that navigates to the init.dart with the LatLng of the pin as argument
  void _addNewPin(coord) async {
    Pin? newPin = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            InitializeTripWidget(data: coord, camera: firstCamera)));

    /// If a newPin was indeed created (user didn't click cancel), redraw widget
    if (newPin != null) {
      final newId = await sqLiteService.addPins(newPin);
      newPin.id = newId;

      _pins.add(newPin);
      _markers.add(_markerFromPin(newPin));
      setState(() {});
    }
  }

  /// void that navigates to the edit.dart with the Pin as argument
  void _editPin(pin) async {
    Pin? editedPin = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditTripWidget(data: pin, camera: firstCamera)));

    var index = _pins.indexOf(pin);

    try {
      sqLiteService.deletePins(pin.id);
      _pins.removeAt(index);
      _markers.removeAt(index);
    } catch (err) {
      debugPrint('Could not delete pin $pin: $err');
    }

    /// If remove button wasn't pressed, insert the newPin in the _pins List
    if (editedPin != null) {
      final newId = await sqLiteService.addPins(editedPin);
      editedPin.id = newId;

      _pins.add(editedPin);
      _markers.add(_markerFromPin(editedPin));
    }

    setState(() {});
  }

  /// Constractor [Widget] of the Homepage
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      /// AppBar with bottom for the Search tab and the Settings FAB
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          /// Title of the Homepage
          title: Center(child: Text("Travelly")),

          /// Bottom for the Search tab and the Settings FAB
          bottom: PreferredSize(
            /// Να το δούμε σχεδιαστικά
            preferredSize: Size.fromHeight(90),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none),
                          hintText: 'Search text',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 17),
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () => _search(_titleController.text)),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: FloatingActionButton.small(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingPageUI(),
                                  ));
                            },
                            child: const Icon(Icons.settings_outlined),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14.0))))),
                  ],
                )),
          )),

      extendBodyBehindAppBar: true,

      /// BottomAppBar with 'Profile', 'Home and 'Messages' buttons
      bottomNavigationBar: BottomNavigationBar(
          //showSelectedLabels: false,
          //showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.person_alt_circle),
                label: 'Profile'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.chat_bubble_2), label: 'Chat')
          ],
          currentIndex: 1,
          //      selectedItemColor: Colors.black,
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        Profile_screen(data: _onlyCoord(_pins))));
                break;
              case 2:
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatWidget(data: _pins)));
                break;
            }
          }),

      /// Body of the Homepage (scrollable and 'pin-able' map)
      body: Center(
          child: FlutterMap(
        options: MapOptions(
            onLongPress: (n, p) async {
              setState(() {
                coord = p;
              });
              HapticFeedback.vibrate();
            },
            center: coord,
            zoom: 5.0,
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate),
        children: [
          TileLayer(
              urlTemplate: isDarkMode
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                  : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c']),
          MarkerLayer(
            markers: [
                  Marker(
                      width: 80.0,
                      height: 80.0,
                      point: coord,
                      builder: (ctx) => Container(
                          child: IconButton(
                              icon: const Icon(Icons.location_on_sharp,
                                  color: Colors.indigo),
                              onPressed: () => _addNewPin(coord))))
                ] +
                _markers,
          ),
        ],
      )),

      /// GPS FAB
      floatingActionButton: FloatingActionButton.small(
        heroTag: "btn0", // χωρίς αυτό: EXCEPTION CAUGHT BY SCHEDULER LIBRARY
        tooltip: 'GPS',
        onPressed: () {
          _GPSAlertDialog();
        },
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }

//  Position? _position;

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _locationPermission();
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      LatLng _position = LatLng(position.latitude, position.longitude);
      _addNewPin(_position);
    }).catchError((e) {
      debugPrint(e);
    });
//      _position = position;
//      print(_position);
//      String long = position.longitude.toString();
//      String lat = position.latitude.toString();

//      LatLng gpscoord = LatLng(
//          double.parse(lat),
//          double.parse(
//              long)); /////// To antistrofo apeu8eias _position.latitude, _position.longtitude
  }

  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<bool> _locationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions')));
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  void _GPSAlertDialog() async {
    bool? openGPS = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text.rich(TextSpan(
                  text: 'Would you like to share your location? \n\n',
                  children: [
                    TextSpan(
                        text:
                            'A pinpoint will be placed according to \nyour current location and you will be \nnavigated to the initialization page.',
                        style: TextStyle(fontSize: 14))
                  ])),
              actions: <Widget>[
                /// If Nope is chosen, openGPS will return false
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Nope')),

                /// If Yep is chosen, openGPS will return true
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yep')),
              ],
            ));

    /// In the case of Yep GPS is activated and so the location (LatLong) of the user is provided
    if (openGPS!) {
      _getCurrentLocation();
    }
  }

  void _search(text) async {
    List<Location> locations = await locationFromAddress(text);
    LatLng searchedCoord =
        LatLng(locations[0].latitude, locations[0].longitude);
    setState(() {
      coord = searchedCoord;
    });
  }
}
