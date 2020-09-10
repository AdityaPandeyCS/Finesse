/// A Finesse Nation User.
///
/// Contains fields that are used when updating notification settings,
/// posting Finesses, and commenting.
class User {
  /// This user's email.
  String email;

  /// This user's password.
  String password;

  /// This user's username.
  String userName;

  /// This user's email.
  String school;

  /// This user's current points.
  int points;

  /// This user's notification preferences.
  bool notifications;

  /// This user's upvoted posts.
  List<String> upvoted;

  /// This user's downvoted posts.
  List<String> downvoted;

  /// This user's subscribed posts.
  List<String> subscriptions;

  /// The current logged in user.
  static User currentUser;

  /// Creates a new user.
  User(this.email, this.password, this.userName, this.school, this.points,
      this.notifications, this.upvoted, this.downvoted, this.subscriptions);

  /// Creates a new user from the given [json] object.
  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
      json['emailId'],
      json['password'],
      json['userName'],
      json['school'],
      json['points'],
      json['notifications'],
      List<String>.from(json['upvoted']),
      List<String>.from(json['downvoted']),
      List<String>.from(json['subscriptions'] ?? []),
    );
    return user;
  }
}
