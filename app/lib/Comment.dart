import 'package:finesse_nation/User.dart';

/// A message left by a [User] on a [Finesse].
class Comment {
  /// This comment's content.
  String comment;

  /// This comment's author's email.
  String emailId;

  /// The time this comment was posted.
  String postedTime;

  /// Creates a comment.
  Comment(this.comment, this.emailId, this.postedTime);

  /// Returns this comment's author's username.
  get username => emailId.split('@')[0];

  /// Creates a comment using the current user and time.
  static Comment post(String comment) {
    String emailId = User.currentUser.email;
    String postedTime = DateTime.now().toString();
    return Comment(comment, emailId, postedTime);
  }

  /// Creates a comment from the [json] object.
  static Comment fromJson(var json) {
    String comment = json['comment'];
    String emailId = json['emailId'];
    String postedTime = json['postedTime'];
    return Comment(comment, emailId, postedTime);
  }

  /// Returns [postedTime] as a DateTime object.
  DateTime get postedDateTime => DateTime.parse(postedTime);

  /// Returns a [Map] containing this comment's fields.
  Map toMap() {
    var map = Map<String, String>();
    map['comment'] = comment;
    map['emailId'] = emailId;
    map['postedTime'] = postedTime;
    return map;
  }
}
