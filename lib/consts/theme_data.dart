import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    if (isDarkTheme) {
      return ThemeData(
        primaryColor: Colors.grey[800],
        colorScheme: ThemeData()
            .colorScheme
            .copyWith(secondary: Colors.blue, brightness: Brightness.dark),
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Pacifico',
            fontSize: 30,
          ),
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.grey[800],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
        ),
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        cardColor: Colors.grey[900],
      );
    } else {
      return ThemeData(
        primaryColor: Colors.white,
        colorScheme: ThemeData()
            .colorScheme
            .copyWith(secondary: Colors.blue, brightness: Brightness.light),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'Pacifico',
            fontSize: 30,
          ),
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
        ),
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        cardColor: Colors.grey[200],
      );
    }
  }
}
