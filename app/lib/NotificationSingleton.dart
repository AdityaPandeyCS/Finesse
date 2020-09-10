import 'package:finesse_nation/NotificationEntry.dart';
import 'package:flutter/cupertino.dart';

class NotificationSingleton extends ValueNotifier<List<NotificationEntry>> {
  List<NotificationEntry> notifications;
  static NotificationSingleton _instance;

  static NotificationSingleton get instance =>
      _instance ?? NotificationSingleton._([]);

  NotificationSingleton._(List<NotificationEntry> notifs) : super(notifs) {
    notifications = notifs;
    _instance = this;
  }

  void addNotification(NotificationEntry newNotification) {
    if (newNotification.type == NotificationType.post) {
      notifications.insert(0, newNotification);
    } else {
      // merge notifications about comments on the same post
      int oldLength = notifications.length;
      notifications.removeWhere((notif) =>
          notif.finesse.eventId == newNotification.finesse.eventId &&
          notif.type == NotificationType.comment &&
          notif.isUnread);
      if (notifications.length != oldLength) {
        newNotification.body = 'new comments';
      }
      notifications.insert(0, newNotification);
    }
    notifyListeners();
  }

  void dismissAll() {
    notifications.clear();
    notifyListeners();
  }

  void markAllAsRead() {
    notifications.forEach((notification) {
      notification.isUnread = false;
    });
    notifyListeners();
  }
}
