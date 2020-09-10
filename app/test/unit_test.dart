import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/User.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

///Misc Supplemental unit tests to increase code coverage
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(
      {"typeFilter": false, "activeFilter": false});
  User.currentUser =
      User('test@test.com', 'test123', 'test', 'test', 0, true, [], [], []);

  ///Basic username getter test
  test('Get UserName test', () {
    User testUser = User("this._email", "this._password", "UserName",
        "this._school", 0, false, [], [], []);
    expect(testUser.userName, "UserName");
  });

  ///Basic setter test for id in finesse
  test('setId', () {
    Finesse newFinesse = Finesse.finesseAdd(
        "setId unit test",
        "Description:",
        null,
        "Activities and Recreation Center",
        "60 hours",
        "Food",
        new DateTime.now());
    expect(newFinesse.eventId, null);
    newFinesse.eventId = "12323413512341234";
    expect(newFinesse.eventId, "12323413512341234");
  });

  ///Basic setter test for active in finesse
  test('setActive', () {
    Finesse newFinesse = Finesse.finesseAdd(
        "setId unit test",
        "Description:",
        null,
        "Activities and Recreation Center",
        "60 hours",
        "Food",
        new DateTime.now());
    expect(newFinesse.markedInactive, []);
    List<String> activeList = ["person1", "person2"];
    newFinesse.markedInactive = activeList;
    expect(newFinesse.markedInactive, activeList);
  });

  ///Checking getter on comment postedDateTime
  test('Comment datetime', () {
    String now = DateTime.now().toString();
    Comment comment = Comment("comment", "emailId", now);
    expect(comment.postedDateTime, DateTime.parse(now));
  });

  ///Checking getter on post command
  test('Comment post', () {
    String commentStr = "I like this comment";
    Comment comment = Comment.post(commentStr);
    expect(comment.comment, commentStr);
  });
}
