import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/NotificationEntry.dart';
import 'package:finesse_nation/NotificationSingleton.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:finesse_nation/Pages/LeaderboardPage.dart';
import 'package:finesse_nation/Pages/LoginScreen.dart';
import 'package:finesse_nation/Pages/NotificationsPage.dart';
import 'package:finesse_nation/Pages/SettingsPage.dart';
import 'package:finesse_nation/Pages/addEventPage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/widgets/FinesseList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicorndial/unicorndial.dart';

bool fcmIsSetup = false;

/// The entrypoint for the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String _currentUser = _prefs.get('currentUser');
  if (_currentUser != null && _currentUser != 'anon') {
    updateCurrentUser(email: _currentUser);
  }
  runApp(_MyApp(_currentUser));
}

class _MyApp extends StatelessWidget {
  final String _currentUser;

  _MyApp(this._currentUser);

  @override
  Widget build(BuildContext context) {
    changeStatusColor(primaryBackground);
    changeNavigationColor(primaryBackground);
    TextStyle font = GoogleFonts.comfortaa();
    TextTheme Function([TextTheme]) fontTheme = GoogleFonts.comfortaaTextTheme;

    return MaterialApp(
      title: 'Finesse',
      theme: ThemeData(
        primaryColor: primaryBackground,
        canvasColor: secondaryBackground,
        accentColor: primaryHighlight,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: primaryHighlight),
          textTheme: fontTheme(
            TextTheme(
              headline6: TextStyle(
                color: primaryHighlight,
                fontSize: 20,
              ),
            ),
          ),
        ),
        textTheme: fontTheme(
          Theme.of(context).textTheme,
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: font,
        ),
      ),
      home: _currentUser != null ? HomePage() : LoginScreen(),
    );
  }
}

/// Displays the [FinesseList].
class HomePage extends StatefulWidget {
  final initialIndex;

  HomePage({Key key, this.initialIndex: 0}) : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // https://github.com/FirebaseExtended/flutterfire/issues/2012#issuecomment-615479602
  Map<String, dynamic> fixMessageTitleAndBody(Map<String, dynamic> message) {
    if (!message.containsKey("notification")) {
      message["notification"] = {};
    }
    if (!message["notification"].containsKey("title") &&
        message["data"].containsKey("title")) {
      message["notification"]["title"] = message["data"]["title"];
    }
    if (!message["notification"].containsKey("body") &&
        message["data"].containsKey("body")) {
      message["notification"]["body"] = message["data"]["body"];
    }
    return message;
  }

  Future<dynamic> handleNotification(Map<String, dynamic> message) async {
    print('HANDLE NOTIFICATION');
    print(message);
    message = fixMessageTitleAndBody(message);
    print(message);

    String id = message['data']['id'];
    NotificationType type = message['data']['type'] == 'post'
        ? NotificationType.post
        : NotificationType.comment;

    Finesse fin;
    fin = await getFinesse(id);

    if (type == NotificationType.comment) {
      fin.comments = await getComments(id);
    }
    print('ABOUT TO PUSH');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinessePage(
          fin,
          false,
          scrollDown: type == NotificationType.comment,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!fcmIsSetup) {
      print('setting up fcm');
      if (!kIsWeb) {
        firebaseMessaging.requestNotificationPermissions();
      }
      firebaseMessaging.subscribeToTopic(ALL_TOPIC);
      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('HANDLE NOTIFICATION');
          print("onMessage: $message");

          String author = message['data']['author'];
//          if (author == User.currentUser.email) return;

          String title = message['notification']['title'];
          String body = message['notification']['body'];
          String id = message['data']['id'];
          NotificationType type = message['data']['type'] == 'post'
              ? NotificationType.post
              : NotificationType.comment;
          // TODO: make finessepage fields futurebuilder?
          Finesse fin = await getFinesse(id);
          if (type == NotificationType.comment) {
            fin.comments = await getComments(id);
          }
          NotificationSingleton.instance
              .addNotification(NotificationEntry(title, body, fin, type));
        },
        onResume: handleNotification,
        onLaunch: handleNotification,
      );
      fcmIsSetup = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(User.currentUser != null
                              ? 'https://picsum.photos/seed/${User.currentUser.email}/100'
                              : 'https://i.imgur.com/hD1SzLR.jpg'),
                          radius: 25,
                        ),
                      ),
                      Text(
                        User.currentUser?.userName ?? 'Not signed in',
                        style: TextStyle(color: primaryHighlight, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: primaryBackground,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: primaryHighlight,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(color: primaryHighlight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.format_list_numbered,
                  color: primaryHighlight,
                ),
                title: Text(
                  'Leaderboard',
                  style: TextStyle(color: primaryHighlight),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardPage()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.fastfood),
                /*child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('ONGOING'),
                    ),
                  ],
                ),*/
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                /*child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('FUTURE'),
                    ),
                  ],
                ),*/
              ),
            ],
          ),
          title: Text('FINESSE'),
          actions: <Widget>[
            ValueListenableBuilder<List<NotificationEntry>>(
              valueListenable: NotificationSingleton.instance,
              builder: (context, notifications, _) {
                return IconButton(
                  icon: Icon(
                    Icons.notifications,
                  ),
                  key: Key("Filter"),
                  color: notifications.any((notif) => notif.isUnread)
                      ? primaryHighlight
                      : secondaryHighlight,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
                      ),
                    );
                    NotificationSingleton.instance.markAllAsRead();
                  },
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            FinesseList(),
            FinesseList(isFuture: true),
          ],
        ),
        floatingActionButton: UnicornDialer(
          hasBackground: false,
          finalButtonIcon: Icon(Icons.close),
          parentButtonBackground: primaryHighlight,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(
            Icons.add,
            color: secondaryBackground,
          ),
          childButtons: [
            UnicornButton(
              hasLabel: true,
              labelText: "Ongoing",
              labelColor: secondaryBackground,
              labelHasShadow: false,
              labelBackgroundColor: primaryHighlight,
              currentButton: FloatingActionButton(
                heroTag: "ongoing",
                backgroundColor: primaryHighlight,
                mini: true,
                child: Icon(
                  Icons.fastfood,
                  color: secondaryBackground,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEvent(true),
                    ),
                  );
                },
              ),
            ),
            UnicornButton(
              hasLabel: true,
              labelText: "Future",
              labelColor: secondaryBackground,
              labelHasShadow: false,
              labelBackgroundColor: primaryHighlight,
              currentButton: FloatingActionButton(
                heroTag: "future",
                backgroundColor: primaryHighlight,
                mini: true,
                child: Icon(
                  Icons.calendar_today,
                  color: secondaryBackground,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEvent(false),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
