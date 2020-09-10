import 'dart:convert';

import 'package:finesse_nation/.env.dart';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/login/flutter_login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Contains functions and constants used to interact with the API.

/// The root domain for the Finesse Nation API.
const _DOMAIN = 'https://finesse-nation.herokuapp.com/api/';
//const _DOMAIN = 'http://10.157.193.217:8080/api/';

/// Deleting a Finesse.
const _DELETE_URL = _DOMAIN + 'food/deleteEvent';

/// Adding an ongoing Finesse.
const _ADD_URL = _DOMAIN + 'food/addEvent';

/// Creating, reading, updating, and deleting future Finesses.
const _FUTURE_URL = _DOMAIN + 'future/';

/// Getting the Finesses.
const _GET_URL = _DOMAIN + 'food/getEvents';

/// Getting the leaderboard.
const _GET_LEADERBOARD_URL = _DOMAIN + 'user/getLeaderboard?currentEmail=';

/// Adding a comment.
const _ADD_COMMENT_URL = _DOMAIN + 'comment';

/// Getting a comment.
const _GET_COMMENT_URL = _DOMAIN + 'comment/';

/// Updating a Finesse.
const _UPDATE_URL = _DOMAIN + 'food/updateEvent';

/// Logging in with an existing account.
const _LOGIN_URL = _DOMAIN + 'user/login';

/// Creating a new account.
const _SIGNUP_URL = _DOMAIN + 'user/signup';

/// Resetting a password.
const _PASSWORD_RESET_URL = _DOMAIN + 'user/generatePasswordResetLink';

/// Toggling a user's notifications.
const _NOTIFICATION_TOGGLE_URL = _DOMAIN + 'user/changeNotifications';

/// Getting a specific user's information.
const _GET_CURRENT_USER_URL = _DOMAIN + 'user/getCurrentUser';

/// Interacting with Firebase Cloud Messaging.
final firebaseMessaging = FirebaseMessaging();

/// Updating the [currentUser]'s voted posts.
const _SET_VOTES_URL = _DOMAIN + 'user/setVotes';

/// The topic used to send notifications about new Finesses.
const ALL_TOPIC = 'newpost';

/// The authentication key for all API calls.
final _token = environment['FINESSE_API_TOKEN'];

/// Send a POST request containing [data] to the [url].
Future<http.Response> _postData(var url, var data) async {
  return await http.post(url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'api_token': _token
      },
      body: json.encode(data));
}

/// Adds [newFinesse].
Future<String> addFinesse(Finesse newFinesse, bool isOngoing) async {
  String url = isOngoing ? _ADD_URL : _FUTURE_URL;
  Map bodyMap = newFinesse.toMap();
  http.Response response = await _postData(url, bodyMap);
  final int statusCode = response.statusCode;
  if (statusCode != 200 && statusCode != 201) {
    throw Exception("Error while posting data");
  }
  return response.body;
}

/// Gets Finesses.
Future<List<Finesse>> fetchFinesses({bool isFuture: false}) async {
  final response = await http.get(
    isFuture ? _FUTURE_URL : _GET_URL,
    headers: {
      'api_token': _token,
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<Finesse> responseJson =
        data.map<Finesse>((json) => Finesse.fromJson(json)).toList();
//    responseJson = await applyFilters(responseJson);
    return responseJson;
  } else {
    throw Exception('Failed to load finesses');
  }
}

Future<Finesse> getFinesse(String eventId) async {
  final response =
      await http.get(_GET_URL + '/$eventId', headers: {'api_token': _token});
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    Finesse fin = Finesse.fromJson(data);
    return fin;
  } else {
    throw Exception('Failed to get finesse $eventId');
  }
}

Future<List<dynamic>> getLeaderboard() async {
  if (User.currentUser != null) {
    updateCurrentUser();
  }
  String email = User.currentUser?.email ?? '';
  final response = await http
      .get(_GET_LEADERBOARD_URL + email, headers: {'api_token': _token});
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    int currentRank = data[0];
    data = data[1];
    List<User> leaderboard =
        data.map<User>((json) => User.fromJson(json)).toList();
    return [currentRank, leaderboard];
  } else {
    throw Exception('Failed to get leaderboard');
  }
}

/// Filters the current Finesses by status/type
Future<List<Finesse>> applyFilters(responseJson) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool activeFilter = prefs.getBool('activeFilter') ?? true;
  final bool typeFilter = prefs.getBool('typeFilter') ?? true;
  List<Finesse> filteredFinesses = List<Finesse>.from(responseJson);

  if (activeFilter == false) {
    filteredFinesses.removeWhere((fin) =>
        !fin.isActive || fin.markedInactive.contains(User.currentUser.email));
  }
  if (typeFilter == false) {
    filteredFinesses.removeWhere((fin) => fin.category == "Other");
  }
  return filteredFinesses;
}

/// Removes [newFinesse].
Future<void> removeFinesse(Finesse newFinesse) async {
  var jsonObject = {"eventId": newFinesse.eventId};
  http.Response response = await _postData(_DELETE_URL, jsonObject);

  if (response.statusCode != 200) {
    throw new Exception("Error while removing finesse");
  }
}

/// Updates [newFinesse].
Future<void> updateFinesse(Finesse newFinesse, {bool isFuture = false}) async {
  String eventId = newFinesse.eventId;
  var jsonObject = {"eventId": eventId};
  var bodyMap = newFinesse.toMap();
  bodyMap.addAll(jsonObject);
  http.Response response;
  if (isFuture) {
    response = await http.put(_FUTURE_URL + eventId,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'api_token': _token
        },
        body: json.encode(bodyMap));
  } else {
    response = await _postData(isFuture ? _FUTURE_URL : _UPDATE_URL, bodyMap);
  }

  if (response.statusCode >= 400) {
    throw new Exception("Error while updating finesse");
  }
}

/// Attempts to login using the credentials in [data].
///
/// Returns an error message on failure, null on success.
Future<String> authUser(LoginData data) async {
  Map bodyMap = data.toMap();
  http.Response response = await _postData(_LOGIN_URL, bodyMap);

  var status = response.statusCode;
  if (status == 400) {
    return 'Username or password is incorrect.';
  }
  await updateCurrentUser(email: data.email);
  return null;
}

/// Attempts to reset the password associated with [email].
///
/// Returns an error message on failure, null on success.
Future<String> recoverPassword(String email) async {
  email = email.trim();
  var emailCheck = validateEmail(email);
  const _VALID_STATUS = null;
  if (emailCheck == _VALID_STATUS) {
    var payload = {"emailId": email};
    http.Response response = await _postData(_PASSWORD_RESET_URL, payload);
    if (response.statusCode == 200) {
      return null;
    } else {
      return "Password Reset request failed";
    }
  } else {
    return emailCheck;
  }
}

/// Attempts to sign up using the credentials in [data].
///
/// Returns an error message on failure, null on success.
Future<String> createUser(LoginData data) async {
  String email = data.email;
  email = email.trim();
  String password = data.password;
  var payload = {
    "emailId": email,
    "password": password,
  };
  http.Response response = await _postData(_SIGNUP_URL, payload);

  var status = response.statusCode, respBody = json.decode(response.body);
  if (status == 400) {
    return respBody['msg'];
  }
  await updateCurrentUser(email: data.email);
  return null;
}

/// Validates [email].
String validateEmail(String email) {
  RegExp validEmail =
      RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-zA-Z0-9])?)*$");

  if (email.isEmpty ||
      !validEmail.hasMatch(email) ||
      !email.endsWith('@illinois.edu')) {
    return 'Please enter a valid illinois.edu email address';
  }

  return null;
}

/// Validates [password].
String validatePassword(String password) {
  return password.length < 6 ? 'Password must be at least 6 characters' : null;
}

/// Changes the current user's notification preferences to [toggle].
Future<void> changeNotifications(bool toggle) async {
  var payload = {"emailId": User.currentUser.email, 'notifications': toggle};
  http.Response response = await _postData(_NOTIFICATION_TOGGLE_URL, payload);
  if (response.statusCode == 200) {
    User.currentUser.notifications = toggle;
  } else {
    throw Exception('Notification change request failed');
  }
}

Future<void> setVotes() async {
  var payload = {
    "emailId": User.currentUser.email,
    'upvoted': User.currentUser.upvoted,
    'downvoted': User.currentUser.downvoted,
  };
  http.Response response = await _postData(_SET_VOTES_URL, payload);
  if (response.statusCode != 200) {
    throw Exception('set votes request failed');
  }
}

/// Sets the notification preferences for the current user.
Future<void> notificationsSet(toggle, {updateUser: true}) async {
  if (toggle) {
    if (User.currentUser != null) {
      for (String topic in User.currentUser.subscriptions) {
        firebaseMessaging.subscribeToTopic(topic);
      }
    }
    firebaseMessaging.subscribeToTopic(ALL_TOPIC);
  } else {
    firebaseMessaging.deleteInstanceID();
  }
  if (User.currentUser != null && updateUser) {
    changeNotifications(toggle);
  }
}

/// Populates the current user fields using [email].
Future<void> updateCurrentUser({String email}) async {
  email = email ?? User.currentUser.email;
  var payload = {"emailId": email};
  http.Response response = await _postData(_GET_CURRENT_USER_URL, payload);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    User.currentUser = User.fromJson(data);
    await notificationsSet(User.currentUser.notifications, updateUser: false);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('currentUser', email);
    });
//    if (User.currentUser.notifications) {
//      for (String topic in User.currentUser.subscriptions) {
//        firebaseMessaging.subscribeToTopic(topic);
//      }
//    }
  } else {
    throw Exception('Failed to get current user');
  }
}

/// Adds [comment] to the Finesse with the given [eventId].
Future<http.Response> addComment(Comment comment, String eventId) async {
  Map bodyMap = comment.toMap();
  bodyMap['eventId'] = eventId;

  http.Response response = await _postData(_ADD_COMMENT_URL, bodyMap);

  final int statusCode = response.statusCode;
  if (statusCode != 200) {
    throw Exception(
        "Error while adding comment, status = ${response.statusCode},"
        " ${response.body}}");
  }
  return response;
}

/// Gets the comments for a Finesse given its [eventId].
Future<List<Comment>> getComments(String eventId) async {
  final response = await http
      .get(_GET_COMMENT_URL + eventId, headers: {'api_token': _token});

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<Comment> comments =
        data.map<Comment>((json) => Comment.fromJson(json)).toList();
    return comments;
  } else {
    throw Exception("Error while getting comments");
  }
}
