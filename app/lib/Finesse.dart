import 'dart:convert';
import 'dart:typed_data';

import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/User.dart';

enum Repetition { none, daily, weekly, monthly, yearly }

/// An event involving free food/items.
class Finesse {
  /// The unique ID for this Finesse.
  String eventId;

  /// The title of this Finesse.
  String eventTitle;

  /// The description of this Finesse.
  String description;

  /// The image of this Finesse.
  String image;

  /// The location of this Finesse.
  String location;

  /// The duration of this Finesse.
  String duration;

  /// The category of this Finesse (Food/Other).
  String category;

  /// The start time of this Finesse.
  DateTime startTime;

  /// The end time of this Finesse.
  DateTime endTime;

  /// The repetition of this Finesse.
  Repetition repetition;

  /// The list of emailIds of [User]s who have marked this Finesse as inactive.
  List<String> markedInactive;

  /// The base64-encoded image of this Finesse.
  Uint8List convertedImage;

  /// The emailId of the [User] who posted this Finesse.
  String emailId;

  /// The school of the [User] who posted this Finesse.
  String school;

  /// The number of points for this Finesse.
  int points;

  /// The number of comments for this Finesse.
  int numComments;

  /// The comments on this Finesse.
  List<Comment> comments;

  /// The current list of Finesses.
  static List<Finesse> finesseList = [];

  /// Creates a Finesse.
  Finesse(
    String eventId,
    String title,
    String description,
    String image,
    String location,
    String category,
    DateTime startTime,
    List<String> markedInactive,
    String school,
    String emailId,
    int points,
    int numComments, {
    String duration,
    DateTime endTime,
    Repetition repetition,
  }) {
    this.eventId = eventId;
    this.eventTitle = title;
    this.description = description;
    this.image = image;
    this.location = location;
    this.duration = duration;
    this.category = category;
    this.startTime = startTime;
    this.convertedImage = image == null ? null : base64.decode(image);
    this.markedInactive = markedInactive;
    this.school = school;
    this.emailId = emailId;
    this.points = points;
    this.numComments = numComments;
    this.comments = [];
    this.endTime = endTime;
    this.repetition = repetition;
  }

  /// Creates a new ongoing Finesse.
  static Finesse finesseAdd(
    String title,
    String description,
    String image,
    String location,
    String duration,
    String category,
    DateTime startTime, {
    List<String> markedInactive: const <String>[],
    String school,
    String email,
    int points: 1,
    int numComments: 0,
  }) {
    return Finesse(
      null,
      title,
      description,
      image,
      location,
      category,
      startTime,
      markedInactive,
      User.currentUser?.school ?? 'test',
      User.currentUser?.email ?? 'test',
      points,
      numComments,
      duration: duration,
    );
  }

  /// Creates a new future Finesse.
  Finesse.future(
    String title,
    String description,
    String image,
    String location,
    String category,
    DateTime startTime, {
    List<String> markedInactive: const <String>[],
    String school,
    String emailId,
    int points: 1,
    int numComments: 0,
    DateTime endTime,
    Repetition repetition,
  }) {
    this.eventTitle = title;
    this.description = description;
    this.image = image;
    this.location = location;
    this.category = category;
    this.startTime = startTime;
    this.endTime = endTime;
    this.repetition = repetition;
    this.convertedImage = image == null ? null : base64.decode(image);
    this.markedInactive = markedInactive;
    this.school = User.currentUser?.school ?? 'test';
    this.emailId = User.currentUser?.email ?? 'test';
    this.points = points;
    this.numComments = numComments;
    this.comments = [];
  }

  /// Creates a Finesse from [json].
  factory Finesse.fromJson(Map<String, dynamic> json) {
    Finesse fin = Finesse(
      json['_id'],
      json['eventTitle'] ?? "",
      json['description'] ?? "",
      json['image'] ?? "",
      json['location'] ?? "",
      json['category'] ?? "",
      DateTime.tryParse(json['startTime'])?.toLocal(),
      List<String>.from(json['isActive']) ?? [],
      json['school'] ?? "",
      json['emailId'] ?? "",
      json['points'] ?? 0,
      json['numComments'] ?? 0,
      duration: json['duration'] ?? "",
      endTime: DateTime.tryParse(json['endTime'] ?? '')?.toLocal(),
      repetition: json['repetition'] != null
          ? Repetition.values.singleWhere(
              (rep) => json['repetition'] == rep.toString(),
              orElse: () => Repetition.none,
            )
          : Repetition.none,
    );
    return fin;
  }

  bool get isActive =>
      markedInactive.length < 3 && !markedInactive.contains(emailId);

  /// Increases this Finesse's points.
  int upvote() => ++points;

  /// Decreases this Finesse's points.
  int downvote() => --points;

  /// Returns a [Map] containing this Finesse's fields.
  Map toMap() {
    var map = Map<String, dynamic>();
    map["eventTitle"] = eventTitle;
    map["description"] = description;
    map["image"] = image;
    map["location"] = location;
    map["duration"] = duration;
    map["category"] = category;
    map['startTime'] = startTime.toUtc().toIso8601String();
    map['endTime'] = endTime?.toUtc()?.toIso8601String();
    map['repetition'] = repetition?.toString();
    map['isActive'] = markedInactive;
    map['school'] = school;
    map['emailId'] = emailId;
    map['points'] = points;
    map['numComments'] = numComments;
    return map;
  }
}
