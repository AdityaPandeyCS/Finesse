import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:finesse_nation/Comment.dart';
import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/widgets/TimeEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

enum DotMenu { markEnded }

/// Displays details about a specific [Finesse].
class FinessePage extends StatefulWidget {
  final Finesse fin;
  final bool isFuture;
  final List<bool> voteStatus;
  final bool scrollDown;

  FinessePage(this.fin, this.isFuture, {voteStatus, scrollDown})
      : this.voteStatus = voteStatus ??
            [
              User.currentUser.upvoted.contains(fin.eventId),
              User.currentUser.downvoted.contains(fin.eventId)
            ],
        this.scrollDown = scrollDown ?? false;

  @override
  _FinessePageState createState() => _FinessePageState();
}

class _FinessePageState extends State<FinessePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Finesse fin;
  bool isFuture;
  List<bool> voteStatus;
  bool scrollDown;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController commentController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final bottomOfPage = new GlobalKey();

  bool _commentIsEmpty = true;

  bool _inEditMode;

  bool deletedImage;
  File _image;

  List<bool> activeStatus;

  Future<List<Comment>> comments;

  DateTime _startDate;
  DateTime _endDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  Repetition selectedRepetition;

//  double width = 8;
//  double gap = 8;
//  bool showSliders = true;

  void resetState() {
    _inEditMode = false;

    deletedImage = false;
    _image = null;

    activeStatus = [fin.isActive, !fin.isActive];

    _startDate = fin.startTime.subtract(
      Duration(
        hours: fin.startTime.hour,
        minutes: fin.startTime.minute,
        seconds: fin.startTime.second,
        milliseconds: fin.startTime.millisecond,
        microseconds: fin.startTime.microsecond,
      ),
    );

    _startTime = TimeOfDay(
      hour: fin.startTime.hour,
      minute: fin.startTime.minute,
    );

    if (fin.endTime != null) {
      _endDate = fin.endTime.subtract(
        Duration(
          hours: fin.endTime.hour,
          minutes: fin.endTime.minute,
          seconds: fin.endTime.second,
          milliseconds: fin.endTime.millisecond,
          microseconds: fin.endTime.microsecond,
        ),
      );
      _endTime = TimeOfDay(
        hour: fin.endTime.hour,
        minute: fin.endTime.minute,
      );
    } else {
      _endDate = null;
      _endTime = null;
    }

    selectedRepetition = fin.repetition ?? Repetition.none;
  }

  @override
  void initState() {
    super.initState();

    fin = widget.fin;
    isFuture = widget.isFuture;
    voteStatus = widget.voteStatus;
    scrollDown = widget.scrollDown;

    resetState();

    comments = getComments(fin.eventId);

    if (scrollDown) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Scrollable.ensureVisible(
          bottomOfPage.currentContext,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget editImageSection;
    if (fin.image == '' || deletedImage) {
      if (_image == null) {
        editImageSection = Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DottedBorder(
                  color: secondaryHighlight,
                  padding: EdgeInsets.all(10),
                  strokeWidth: 1,
                  dashPattern: [8, 8],
                  borderType: BorderType.RRect,
                  radius: Radius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Center(
                      child: Text(
                        'ADD IMAGE',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryHighlight,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  File img = await uploadImagePopup(context);
                  setState(() {
                    if (img != null) _image = img;
                  });
                }, //() => setState(() => showSliders = !showSliders)
              ),
            ),
            /*if (showSliders)
                  Slider(
                    value: width,
                    onChanged: (val) {
                      setState(() {
                        width = val;
                      });
                    },
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '$width',
                  ),
                if (showSliders)
                  Slider(
                    value: gap,
                    onChanged: (val) {
                      setState(() {
                        gap = val;
                      });
                    },
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: '$gap',
                  ),*/
          ],
        );
      } else {
        editImageSection = Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              _image,
              width: 600,
              height: 240,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.luminosity,
              color: Colors.white.withOpacity(0.5),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    File img = await uploadImagePopup(context);
                    setState(() {
                      if (img != null) _image = img;
                    });
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _image = null;
                      deletedImage = true;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      }
    } else if (fin.image != '') {
      editImageSection = Stack(
        alignment: Alignment.center,
        children: [
          if (_image != null)
            Image.file(
              _image,
              width: 600,
              height: 240,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.luminosity,
              color: Colors.white.withOpacity(0.5),
            )
          else
            Image.memory(
              fin.convertedImage,
              width: 600,
              height: 240,
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.luminosity,
              color: Colors.white.withOpacity(0.5),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  File img = await uploadImagePopup(context);
                  setState(() {
                    if (img != null) _image = img;
                  });
                },
                icon: Icon(Icons.edit),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _image = null;
                    deletedImage = true;
                  });
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ],
      );
    }

    Widget imageSection;
    imageSection = InkWell(
      onTap: () async {
        changeStatusColor(Colors.black);
        changeNavigationColor(Colors.black);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullImage(
              fin,
            ),
          ),
        );
        changeStatusColor(primaryBackground);
        changeNavigationColor(primaryBackground);
      },
      child: Hero(
        tag: fin.eventId,
        child: Image.memory(
          fin.convertedImage,
          width: 600,
          height: 240,
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.saturation,
          color: fin.isActive ? Colors.transparent : inactiveColor,
        ),
      ),
    );

    Widget editTitleSection;
    editTitleSection = TextFormField(
      autovalidate: true,
      controller: titleController,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: primaryHighlight,
      ),
      decoration: const InputDecoration(
        hintText: "Title",
        hintStyle: TextStyle(
          color: secondaryHighlight,
        ),
      ),
      validator: (value) => value.isEmpty ? 'Please enter a title' : null,
    );

    Widget titleSection = Container(
      padding: EdgeInsets.only(bottom: 20, top: 15),
      child: Text(
        fin.eventTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: fin.isActive ? primaryHighlight : inactiveColor,
        ),
      ),
    );

    Widget editLocationSection;
    editLocationSection = Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.place,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          Expanded(
            child: TextFormField(
              autovalidate: true,
              controller: locationController,
              style: TextStyle(
                fontSize: 16,
                color: primaryHighlight,
              ),
              decoration: const InputDecoration(
                hintText: "Location",
                hintStyle: TextStyle(
                  color: secondaryHighlight,
                ),
              ),
              validator: (value) =>
                  value.isEmpty ? 'Please enter a location' : null,
            ),
          ),
        ],
      ),
    );

    Widget locationSection = Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.place,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: () =>
                  launch('https://www.google.com/maps/search/${fin.location}'),
              child: Text(
                fin.location,
                style: TextStyle(
                  fontSize: 16,
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget editDescriptionSection;
    editDescriptionSection = Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(
            Icons.short_text,
            color: fin.isActive
                ? fin.isActive ? secondaryHighlight : inactiveColor
                : inactiveColor,
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: descriptionController,
            style: TextStyle(
              fontSize: 16,
              color: primaryHighlight,
            ),
            decoration: const InputDecoration(
              hintText: "Description",
              hintStyle: TextStyle(
                color: secondaryHighlight,
              ),
            ),
          ),
        ),
      ],
    );

    Widget descriptionSection = Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.short_text,
              color: fin.isActive
                  ? fin.isActive ? secondaryHighlight : inactiveColor
                  : inactiveColor,
            ),
          ),
          Flexible(
            child: SelectableLinkify(
              text: fin.description,
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
              ),
              linkStyle: TextStyle(color: secondaryHighlight),
              options: LinkifyOptions(
                removeWww: true,
              ),
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                } else {
                  throw 'Could not launch $link';
                }
              },
            ),
          ),
        ],
      ),
    );

    Widget editTimeContent;

    Widget timeContent;

    if (!isFuture) {
      if (_inEditMode) {
        editTimeContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: ToggleButtons(
                fillColor: Colors.transparent,
                splashColor: Colors.transparent,
                selectedColor: primaryHighlight,
                color: secondaryHighlight,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      'Ongoing',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      'Inactive',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < activeStatus.length;
                        buttonIndex++) {
                      if (buttonIndex == index) {
                        setState(() {
                          activeStatus[buttonIndex] = true;
                        });
                      } else {
                        setState(() {
                          activeStatus[buttonIndex] = false;
                        });
                      }
                    }
                  });
                },
                isSelected: activeStatus,
              ),
            ),
            if (activeStatus[0])
              TextFormField(
                controller: durationController,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryHighlight,
                ),
                decoration: const InputDecoration(
                  hintText: 'Duration',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: secondaryHighlight,
                  ),
                ),
              ),
          ],
        );
      } else {
        if (!fin.isActive) {
          timeContent = Text(
            'Inactive',
            style: TextStyle(
              fontSize: 16,
              color: inactiveColor,
            ),
          );
        } else {
          timeContent = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fin.duration != '')
                  Flexible(
                    child: Text(
                      'Duration: ' + fin.duration,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryHighlight,
                      ),
                    ),
                  ),
                Text(
                  'Posted ' + timeago.format(fin.startTime),
                  style: TextStyle(
                    fontSize: fin.duration != '' ? 14 : 16,
                    color: fin.duration != ''
                        ? secondaryHighlight
                        : primaryHighlight,
                  ),
                ),
              ],
            ),
          );
        }
      }
    } else if (isFuture && fin.endTime == null) {
      if (_inEditMode) {
        editTimeContent = TimeEntry(
          initStartDate: _startDate,
          initStartTime: _startTime,
          initEndDate: _endDate,
          initEndTime: _endTime,
          initRepetition: selectedRepetition,
          onSelectStartDate: (date) {
            _startDate = date;
          },
          onSelectStartTime: (time) {
            _startTime = time;
          },
          onSelectEndDate: (date) {
            _endDate = date;
          },
          onSelectEndTime: (time) {
            _endTime = time;
          },
          onSelectRepetition: (rep) {
            selectedRepetition = rep;
          },
        );
      } else {
        timeContent = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (fin.startTime.year == DateTime.now().year)
                    ? DateFormat('EEEE, MMMM d').format(fin.startTime)
                    : DateFormat('EEEE, MMMM d, y').format(fin.startTime),
                style: TextStyle(
                  fontSize: 16,
                  color: primaryHighlight,
                ),
              ),
              Text(
                DateFormat('h:m a').format(fin.startTime),
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryHighlight,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // isFuture, endTime provided
      if (_inEditMode) {
        editTimeContent = TimeEntry(
          initStartDate: _startDate,
          initStartTime: _startTime,
          initEndDate: _endDate,
          initEndTime: _endTime,
          initRepetition: selectedRepetition,
          onSelectStartDate: (date) {
            _startDate = date;
          },
          onSelectStartTime: (time) {
            _startTime = time;
          },
          onSelectEndDate: (date) {
            _endDate = date;
          },
          onSelectEndTime: (time) {
            _endTime = time;
          },
          onSelectRepetition: (rep) {
            selectedRepetition = rep;
          },
        );
      } else {
        if (_startDate.isAtSameMomentAs(_endDate)) {
          timeContent = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (fin.startTime.year == DateTime.now().year)
                      ? DateFormat('EEEE, MMMM d').format(fin.startTime)
                      : DateFormat('EEEE, MMMM d, y').format(fin.startTime),
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryHighlight,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(fin.startTime) +
                      ' - ' +
                      DateFormat('h:mm a').format(fin.endTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryHighlight,
                  ),
                ),
              ],
            ),
          );
        } else {
          // startdate != enddate
          timeContent = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ((fin.startTime.year == DateTime.now().year)
                          ? DateFormat('EEEE, MMMM d').format(fin.startTime)
                          : DateFormat('EEEE, MMMM d, y')
                              .format(fin.startTime)) +
                      ' · ' +
                      DateFormat('h:mm a').format(fin.startTime),
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryHighlight,
                  ),
                ),
                Text(
                  ((fin.endTime.year == DateTime.now().year)
                          ? DateFormat('EEEE, MMMM d').format(fin.endTime)
                          : DateFormat('EEEE, MMMM d, y').format(fin.endTime)) +
                      ' · ' +
                      DateFormat('h:mm a').format(fin.endTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryHighlight,
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

    Widget editTimeSection;
    editTimeSection = Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        crossAxisAlignment:
            (false) ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: (false)
                ? const EdgeInsets.only(top: 12, right: 10)
                : const EdgeInsets.only(top: 0, right: 10),
            child: Icon(
              Icons.calendar_today,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          if (editTimeContent != null)
            Expanded(
              child: editTimeContent,
            ),
        ],
      ),
    );

    Widget timeSection = Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.calendar_today,
              color: fin.isActive ? secondaryHighlight : inactiveColor,
            ),
          ),
          if (timeContent != null) timeContent,
        ],
      ),
    );

    Widget userSection = Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundImage:
                  NetworkImage('https://picsum.photos/seed/${fin.emailId}/100'),
              radius: 12,
            ),
          ),
          Flexible(
            child: Text(
              fin.emailId,
              style: TextStyle(
                fontSize: 16,
                color: fin.isActive ? primaryHighlight : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );

    Widget votingSection = Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.thumbs_up_down,
                  color: fin.isActive ? secondaryHighlight : inactiveColor,
                ),
              ),
              Text(
                '${fin.points} ${(fin.points == 1) ? "point" : "points"}',
                style: TextStyle(
                  fontSize: 16,
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                ),
              ),
            ],
          ),
          if (fin.isActive)
            SizedBox(
              height: 24,
              child: ToggleButtons(
                renderBorder: false,
                fillColor: Colors.transparent,
                splashColor: Colors.transparent,
                selectedColor: primaryHighlight,
                color: fin.isActive ? secondaryHighlight : inactiveColor,
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
                      handleVote(index, voteStatus, fin);
                    });
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
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
                isSelected: voteStatus,
              ),
            ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );

    Future<void> postComment(String comment) async {
      Comment newComment = Comment.post(comment.trim());
      setState(() => fin.comments.add(newComment));
      addComment(newComment, fin.eventId);
      fin.numComments++;
      commentController.clear();
      /*firebaseMessaging.unsubscribeFromTopic(fin.eventId);
      await sendToAll(fin.eventTitle, '${User.currentUser.userName}: $comment',
          topic: fin.eventId, id: fin.eventId);*/
      firebaseMessaging.subscribeToTopic(fin.eventId);
    }

    Widget addCommentSection = Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundImage: NetworkImage(User.currentUser != null
                  ? 'https://picsum.photos/seed/${User.currentUser.email}/100'
                  : 'https://i.imgur.com/hD1SzLR.jpg'),
              radius: 20,
            ),
          ),
          Expanded(
            child: TextFormField(
              key: bottomOfPage,
              keyboardAppearance: Brightness.dark,
              textCapitalization: TextCapitalization.sentences,
              controller: commentController,
              autovalidate: true,
              validator: (comment) {
                bool isEmpty = comment.isEmpty;
                if (isEmpty != _commentIsEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _commentIsEmpty = isEmpty;
                    });
                  });
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                    color: fin.isActive ? secondaryHighlight : inactiveColor),
              ),
              style: TextStyle(
                  color: fin.isActive ? primaryHighlight : inactiveColor),
              onFieldSubmitted: (comment) async {
                if (comment.isNotEmpty) {
                  if (User.currentUser != null) {
                    await postComment(comment);
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sorry, you must be logged in to comment on a post.',
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
                }
              },
            ),
          ),
          IconButton(
              color: primaryHighlight,
              disabledColor: Colors.grey[500],
              icon: Icon(
                Icons.send,
              ),
              onPressed: (_commentIsEmpty)
                  ? null
                  : () async {
                      if (User.currentUser != null) {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        String comment = commentController.value.text;
                        await postComment(comment);
                      } else {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sorry, you must be logged in to comment on a post.',
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
                    }),
        ],
      ),
    );

    Widget getCommentView(Comment comment) {
      return Padding(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://picsum.photos/seed/${comment.emailId}/100'),
                    radius: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 1),
                        child: Row(
                          children: [
                            Text(
                              comment.username,
                              style: TextStyle(
                                color: fin.isActive
                                    ? primaryHighlight
                                    : inactiveColor,
                              ),
                            ),
                            Text(
                              " · ${timeago.format(comment.postedDateTime)}",
                              style: TextStyle(
                                color: fin.isActive
                                    ? secondaryHighlight
                                    : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        comment.comment,
                        style: TextStyle(
                          color:
                              fin.isActive ? primaryHighlight : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget viewCommentSection = FutureBuilder(
      initialData: fin.comments,
      future: comments,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          fin.comments = snapshot.data;
          fin.numComments = fin.comments.length;
        }
        List<Widget> children =
            fin.comments.map((comment) => getCommentView(comment)).toList();
        Widget commentsHeader = Padding(
          padding: EdgeInsets.only(
            bottom: 10,
          ),
          child: Row(
            children: [
              Text(
                'Comments  ',
                style: TextStyle(
                  fontSize: 16,
                  color: fin.isActive ? primaryHighlight : inactiveColor,
                ),
              ),
              Text(
                '${fin.numComments}',
                style: TextStyle(
                  fontSize: 15,
                  color: fin.isActive ? secondaryHighlight : inactiveColor,
                ),
              ),
            ],
          ),
        );
        children.insert(0, commentsHeader);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      },
    );

    Widget readView = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fin.image != "") imageSection,
        Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              locationSection,
              if (fin.description != "") descriptionSection,
              timeSection,
              userSection,
              votingSection,
              viewCommentSection,
              addCommentSection,
            ],
          ),
        ),
      ],
    );

    Widget editView = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: editImageSection,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 5,
            ),
            child: Column(
              children: [
                editTitleSection,
                editLocationSection,
                editDescriptionSection,
                editTimeSection,
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: !_inEditMode,
        title: Text(
          _inEditMode ? 'Editing \'${fin.eventTitle}\'' : fin.eventTitle,
        ),
        actions: <Widget>[
          if (fin.emailId == User.currentUser?.email)
            if (!_inEditMode)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: primaryHighlight,
                ),
                onPressed: () {
                  setState(() {
                    _inEditMode = true;
                    titleController.text = fin.eventTitle;
                    locationController.text = fin.location;
                    descriptionController.text = fin.description;
                    durationController.text = fin.duration;
                    activeStatus = [fin.isActive, !fin.isActive];
                  });
                },
              )
            else
              Row(
                children: [
                  IconButton(
                      tooltip: 'Submit',
                      icon: Icon(
                        Icons.check,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            if (_image != null) {
                              fin.image =
                                  base64Encode(_image.readAsBytesSync());
                              fin.convertedImage = base64.decode(fin.image);
                            }
                            if (deletedImage) {
                              fin.image = '';
                            }
                            fin.eventTitle = titleController.text;
                            fin.location = locationController.text;
                            fin.description = descriptionController.text;
                            if (activeStatus[0]) {
                              fin.duration = durationController.text;
                              fin.markedInactive.remove(User.currentUser.email);
                            } else {
                              fin.markedInactive.add(User.currentUser.email);
                            }
                            if (isFuture) {
                              DateTime start = _startDate.add(
                                Duration(
                                  hours: _startTime.hour,
                                  minutes: _startTime.minute,
                                ),
                              );
                              fin.startTime = start;

                              if (_endDate != null && _endTime != null) {
                                DateTime end = _endDate.add(
                                  Duration(
                                    hours: _endTime.hour,
                                    minutes: _endTime.minute,
                                  ),
                                );
                                fin.endTime = end;
                              }
                            }

                            resetState();
                          });

                          updateFinesse(fin, isFuture: isFuture);
                        }
                      }),
                  IconButton(
                      tooltip: 'Cancel',
                      icon: Icon(
                        Icons.close,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        bool wasEdited = (_image != null ||
                                (fin.image != '' && deletedImage == true)) ||
                            (titleController.text != fin.eventTitle) ||
                            (locationController.text != fin.location) ||
                            (descriptionController.text != fin.description) ||
                            (activeStatus[0] != fin.isActive) ||
                            (durationController.text != fin.duration);
                        if (wasEdited) {
                          AlertDialog dialog = AlertDialog(
                            backgroundColor: secondaryBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(
                              'Discard changes?',
                              style: TextStyle(
                                color: primaryHighlight,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Text(
                                'Are you sure you want to discard your changes to this event?',
                                style: TextStyle(
                                  color: primaryHighlight,
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'NO',
                                  style: TextStyle(
                                    color: secondaryHighlight,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  'YES',
                                  style: TextStyle(
                                    color: secondaryHighlight,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    resetState();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                          showDialog(
                            context: context,
                            builder: (_) => dialog,
                          );
                        } else {
                          setState(() {
                            resetState();
                          });
                        }
                      }),
                  IconButton(
                      tooltip: 'Delete',
                      icon: Icon(
                        Icons.delete,
                        color: primaryHighlight,
                      ),
                      onPressed: () {
                        AlertDialog dialog = AlertDialog(
                          backgroundColor: secondaryBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Text(
                            'Delete?',
                            style: TextStyle(
                              color: primaryHighlight,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              'Are you sure you want to delete this event? If the event is over, please mark it as \'inactive\' instead.',
                              style: TextStyle(
                                color: primaryHighlight,
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                'NO',
                                style: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text(
                                'YES',
                                style: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              onPressed: () async {
                                await removeFinesse(fin);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HomePage()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                          ],
                        );
                        showDialog(
                          context: context,
                          builder: (_) => dialog,
                        );
                      }),
                ],
              ),
          /* if (fin.isActive)
            PopupMenuButton<DotMenu>(
              key: Key("threeDotButton"),
              onSelected: (DotMenu result) {
                setState(() {
                  _markAsEnded(fin);
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<DotMenu>>[
                const PopupMenuItem<DotMenu>(
                  key: Key("markAsEndedButton"),
                  value: DotMenu.markEnded,
                  child: Text('Mark as inactive'),
                ),
              ],
            )*/
          if (!_inEditMode && fin.isActive)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () =>
                  Share.share('${fin.eventTitle} at ${fin.location}'),
            ),
        ],
      ),
      backgroundColor: primaryBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: secondaryBackground,
            child: _inEditMode ? editView : readView,
          ),
        ),
      ),
    );
  }
}

/// Displays the full image for the [Finesse].
class FullImage extends StatelessWidget {
  final Finesse fin;

  FullImage(this.fin);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: fin.eventId,
            child: Image.memory(
              fin.convertedImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

void _markAsEnded(Finesse fin) {
  List activeList = fin.markedInactive;
  if (activeList.contains(User.currentUser.email)) {
    Fluttertoast.showToast(
      msg: "Already marked as inactive",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: secondaryBackground,
      textColor: primaryHighlight,
    );
  } else {
    activeList.add(User.currentUser.email);
    updateFinesse(fin);
    Fluttertoast.showToast(
      msg: "Marked as inactive",
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: secondaryBackground,
      textColor: primaryHighlight,
    );
  }
}
