import 'package:flutter/cupertino.dart';

import '../services/dark_theme_prefs.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemesPrefs darkThemesPrefs = DarkThemesPrefs();
  bool _darkTheme = false;
  bool get getDarkTheme => _darkTheme;

  set setDarkTheme(bool value) {
    _darkTheme = value;
    darkThemesPrefs.setDarkTheme(value);
    notifyListeners(); // this alerts the ChangeNotifier of a change which in turn notifies the widgets
  }
}
