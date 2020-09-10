import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Pages/FinessePage.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class FinesseCard extends StatefulWidget {
  final Finesse fin;
  final bool isFuture;

  FinesseCard(this.fin, this.isFuture);

  @override
  _FinesseCardState createState() => _FinesseCardState();
}

class _FinesseCardState extends State<FinesseCard> {
  Finesse fin;
  bool isFuture;

  List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    fin = widget.fin;
    isFuture = widget.isFuture;

    isSelected = [
      User.currentUser?.upvoted?.contains(fin.eventId) ?? false,
      User.currentUser?.downvoted?.contains(fin.eventId) ?? false
    ];
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: secondaryBackground,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinessePage(
                  fin,
                  isFuture,
                  voteStatus: isSelected,
                ),
              ),
            ).whenComplete(() => setState(() => {}));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (fin.image != "")
                Hero(
                  tag: fin.eventId,
                  child: fin.image == ""
                      ? Container()
                      : Image.memory(
                          fin.convertedImage,
                          width: 600,
                          height: 240,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.saturation,
                          color:
                              fin.isActive ? Colors.transparent : inactiveColor,
                        ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        fin.eventTitle,
                        key: Key("title"),
                        style: TextStyle(
                          fontSize: 17,
                          color:
                              fin.isActive ? primaryHighlight : inactiveColor,
                        ),
                      ),
                    ),
                    Text(
                      isFuture
                          ? DateFormat('E, MMM d · h:m a').format(fin.startTime)
                          : fin.location +
                              ' · ' +
                              timeago.format(fin.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            fin.isActive ? secondaryHighlight : inactiveColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "${fin.points} ${(fin.points == 1) ? "point" : "points"}\n"
                          "${fin.numComments} ${(fin.numComments == 1) ? "comment" : "comments"}",
                          style: TextStyle(
                            fontSize: 12,
                            color: fin.isActive
                                ? secondaryHighlight
                                : inactiveColor,
                          ),
                        ),
                        Visibility(
                          visible: fin.isActive,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: ToggleButtons(
                            renderBorder: false,
                            fillColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            selectedColor: primaryHighlight,
                            color: secondaryHighlight,
                            children: <Widget>[
                              Icon(
                                Icons.arrow_upward,
                              ),
                              Icon(
                                Icons.arrow_downward,
                              ),
                            ],
                            onPressed: (index) {
                              if (User.currentUser != null) {
                                setState(() {
                                  handleVote(index, isSelected, fin);
                                });
                              } else {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sorry, you must be logged in to vote on a post.',
                                      style: TextStyle(
                                        color: secondaryHighlight,
                                      ),
                                    ),
                                    action: SnackBarAction(
                                      label: 'LOGIN',
                                      onPressed: () => logout(context),
                                    ),
                                  ),
                                );
                              }
                            },
                            isSelected: isSelected,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
