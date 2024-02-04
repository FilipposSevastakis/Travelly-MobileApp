import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../provider/dark_theme_provider.dart';
import '../consts/theme_data.dart';
import '../screens/home.dart';

late List<CameraDescription> cameras;
late CameraDescription firstCamera;

/// main function of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  firstCamera = cameras.first;

  await Firebase.initializeApp();

  await Settings.init(cacheProvider: SharePreferenceCache());
  runApp(Travelly());
}

/// Implementation of the main screen of the app as a [StatelessWidget]
class Travelly extends StatefulWidget {
  Travelly({Key? key}) : super(key: key);

  @override
  _TravellyState createState() => _TravellyState();
}

class _TravellyState extends State<Travelly> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemesPrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  /// Constructor [Widget] of the app
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            return themeChangeProvider;
          })
        ],
        child: Consumer<DarkThemeProvider>(
            builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Travelly',
            theme: Styles.themeData(themeProvider.getDarkTheme, context),
            home: const AuthGate(),
          );
        }));
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePageWidget();
        } else {
          return const SignInScreen(
            providerConfigs: [EmailProviderConfiguration()],
          );
        }
      },
    );
  }
}
