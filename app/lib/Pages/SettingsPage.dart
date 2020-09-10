import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:flutter/material.dart';

/// Contains functionality that allows the user to
/// logout and change their notification preferences.
class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Settings';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      backgroundColor: primaryBackground,
      body: SettingsPage(),
    );
  }
}

/// Displays settings.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var toggle = User.currentUser?.notifications ?? true;

  _SettingsPageState createState() {
    return _SettingsPageState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: secondaryBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(right: 15, bottom: 10, top: 10, left: 10),
                  child: Text(
                    'Notifications',
                    style: TextStyle(color: primaryHighlight, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              right: 15, bottom: 10, top: 10, left: 10),
                          child: Switch(
                              key: Key("Notification Toggle"),
                              activeColor: primaryHighlight,
                              value: toggle,
                              onChanged: (value) {
                                setState(() {
                                  toggle = !toggle;
                                });
                                notificationsSet(toggle);
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Notifications " +
                                        (toggle ? "enabled" : "disabled")),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(color: primaryBackground),
            Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        right: 15, bottom: 10, top: 10, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Account',
                          style:
                              TextStyle(color: primaryHighlight, fontSize: 20),
                        ),
                        Text(
                          User.currentUser?.email ?? 'Not signed in',
                          style: TextStyle(
                              color: secondaryHighlight, fontSize: 14),
                        ),
                      ],
                    )),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 15,
                            bottom: 10,
                            top: 10,
                            left: 10,
                          ),
                          child: RaisedButton(
                            key: Key('logoutButton'),
                            color: primaryHighlight,
                            child: Text(
                              User.currentUser != null ? 'LOGOUT' : 'LOGIN',
                              style: TextStyle(color: secondaryBackground),
                            ),
                            onPressed: () => logout(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
//            Divider(color: primaryBackground),
          ],
        ),
      ),
    );
  }
}
