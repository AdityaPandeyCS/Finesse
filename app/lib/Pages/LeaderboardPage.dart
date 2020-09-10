import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:flutter/material.dart';

/// Displays the top 10 users sorted by points.
class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> leaderboard = getLeaderboard();

    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: FutureBuilder(
        future: leaderboard,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ListView(
                children: toLeaderboard(snapshot.data[0], snapshot.data[1]),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

List<Widget> toLeaderboard(int currentRank, List<User> users) {
  List<Widget> leaderboard = [
    Padding(
      padding: EdgeInsets.only(top: 5),
    )
  ];
  for (int i = 0; i < users.length; i++) {
    leaderboard.add(toLeaderboardRow(users[i], i + 1));
  }
  if (User.currentUser != null &&
      !users.any((user) => user.email == User.currentUser.email)) {
    leaderboard.add(
      Icon(
        Icons.more_horiz,
        color: secondaryHighlight,
        size: 50,
      ),
    );
    leaderboard.add(toLeaderboardRow(User.currentUser, currentRank));
  }
  return leaderboard;
}

Widget toLeaderboardRow(User user, int rank) {
  return Card(
    clipBehavior: Clip.hardEdge,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: secondaryBackground,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: secondaryHighlight,
                    fontSize: 20,
                    fontWeight: (user.email == User.currentUser?.email)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/${user.email}/100'),
                  radius: 25,
                ),
              ),
              Text(
                user.userName,
                style: TextStyle(
                  color: primaryHighlight,
                  fontSize: 20,
                  fontWeight: (user.email == User.currentUser?.email)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            user.points.toString(),
            style: TextStyle(
              color: primaryHighlight,
              fontSize: 25,
              fontWeight: (user.email == User.currentUser?.email)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}
