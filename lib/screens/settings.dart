import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../provider/dark_theme_provider.dart';

class SettingPageUI extends StatefulWidget {
  @override
  _SettingPageUIState createState() => _SettingPageUIState();
}

class _SettingPageUIState extends State<SettingPageUI> {
  bool valNotify1 = true;
  bool valNotify2 = false;
  bool valNotify3 = false;

  onChangeFunction1(bool newValue1) {
    setState(() {
      valNotify1 = newValue1;
    });
  }

  onChangeFunction2(bool newValue2) {
    setState(() {
      valNotify2 = newValue2;
    });
  }

  onChangeFunction3(bool newValue3) {
    setState(() {
      valNotify3 = newValue3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
          )),

      /// BottomAppBar
      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.person_alt_circle),
                label: 'Profile'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: const Icon(CupertinoIcons.chat_bubble_2), label: 'Chat')
          ],
          onTap: (int index) {
            switch (index) {
              case 1:
                Navigator.of(context).pop((context));
                break;
//          case 1:,
            }
          }),

      body: SafeArea(
          child: ListView(padding: EdgeInsets.all(10), children: [
        Row(
          children: [
            Icon(Icons.person /*color: Colors.blue*/),
            SizedBox(width: 10),
            Text("Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
          ],
        ),
        Divider(height: 20, thickness: 2),
        SizedBox(height: 10),
        buildAccountOption(context, "Change Password"),
        buildAccountOption(context, "Content Settings"),
        buildAccountOption(context, "Social"),
        buildAccountOption(context, "Language"),
        buildAccountOption(context, "Privacy and Security"),
        SizedBox(height: 40),
        Row(
          children: [
            Icon(Icons.volume_up_outlined /*,color: Color.blue*/),
            SizedBox(width: 10),
            Text("Notifications",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
          ],
        ),
        Divider(height: 20, thickness: 2),
        SizedBox(height: 10),
        buildNotificationOption(
            "Account Active", valNotify2, onChangeFunction2),
        buildNotificationOption("Opportunity", valNotify3, onChangeFunction3),
        Divider(height: 20, thickness: 3),
        SizedBox(height: 10),
        SwitchListTile(
          title: Text(
            "Theme",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          secondary: Icon(themeState.getDarkTheme
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined),
          onChanged: (bool value) {
            setState(() {
              themeState.setDarkTheme = value;
            });
          },
          value: themeState.getDarkTheme,
        ),
        SizedBox(height: 10),
        Center(
            child: ListTile(
          leading: const Icon(Icons.logout),
          title: Text(
            "Logout",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          onTap: () async => await FirebaseAuth.instance.signOut(),
        ))
      ])),
    );
  }

  Padding buildNotificationOption(
      String title, bool value, Function onChangeMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600])),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              activeColor: Colors.blue,
              trackColor: Colors.grey,
              value: value,
              onChanged: (bool newValue) {
                onChangeMethod(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector buildAccountOption(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text("Option 1"), Text("Option 2")],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Close"))
                ],
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600])),
            Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}
