import 'package:finesse_nation/Finesse.dart';

enum NotificationType { post, comment }

class NotificationEntry {
  String title;

  String body;

  Finesse finesse;

  NotificationType type;

  bool isUnread;

  NotificationEntry(this.title, this.body, this.finesse, this.type,
      {this.isUnread = true});
}
