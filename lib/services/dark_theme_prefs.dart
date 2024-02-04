import 'package:shared_preferences/shared_preferences.dart';

class DarkThemesPrefs {
  static const THEME_STATUS = "THEMESTATUS";
  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ??
        false; // ??: false in case that an initial status wasn't given
  }
}
