import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/NotificationEntry.dart';
import 'package:finesse_nation/NotificationSingleton.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:flutter/material.dart';

/// Displays the top 10 users sorted by points.
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.clear_all,
              color: primaryHighlight,
            ),
            onPressed: () {
              setState(() {
                NotificationSingleton.instance.dismissAll();
              });
            },
          )
        ],
      ),
      body: ValueListenableBuilder<List<NotificationEntry>>(
        valueListenable: NotificationSingleton.instance,
        builder: (context, notifications, _) {
          if (notifications.isNotEmpty) {
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                NotificationEntry notif = notifications[i];
                Color color = notif.isUnread ? primaryHighlight : inactiveColor;
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: secondaryBackground,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Icon(
                                notif.type == NotificationType.post
                                    ? Icons.fastfood
                                    : Icons.comment,
                                color: color,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notif.title,
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    notif.body,
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    Finesse fin = notif.finesse;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinessePage(
                          fin,
                          false,
                          scrollDown: notif.type == NotificationType.comment,
                        ),
                      ),
                    );
                    setState(() {
                      notif.isUnread = false;
                    });
                  },
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No unread notifications',
                style: TextStyle(
                  color: secondaryHighlight,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
