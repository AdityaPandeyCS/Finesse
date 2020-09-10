import 'dart:convert';
import 'dart:io';

import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Network.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:finesse_nation/User.dart';
import 'package:finesse_nation/Util.dart';
import 'package:finesse_nation/main.dart';
import 'package:finesse_nation/widgets/TimeEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

/// Allows the user to add a new [Finesse].
class AddEvent extends StatefulWidget {
  final bool isOngoing;

  AddEvent(this.isOngoing);

  @override
  _AddEventState createState() {
    return _AddEventState();
  }
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  final eventNameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final picker = ImagePicker();

  bool isOngoing;

  DateTime _startDate;
  DateTime _endDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  Repetition selectedRepetition;

  String _type = "Food";

  File _image;
  double width = 1200;
  double height = 480;

  bool shouldValidate;

  @override
  void dispose() {
    eventNameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isOngoing = widget.isOngoing;

    shouldValidate = false;

    DateTime now = DateTime.now();
    _startDate = now.subtract(
      Duration(
        hours: now.hour,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      ),
    );

    _startTime = TimeOfDay.now();

    selectedRepetition = Repetition.none;
  }

//  void _onImageButtonPressed(ImageSource source) async {
//    final pickedFile = await picker.getImage(source: source);
//
//    setState(() {
//      _image = File(pickedFile.path);
//    });
//  }

//  Future<void> uploadImagePopup() async {
//    await PopUpBox.showPopupBox(
//      title: "Upload Image",
//      context: context,
//      button: FlatButton(
//        key: Key("UploadOK"),
//        onPressed: () {
//          Navigator.of(context, rootNavigator: true).pop();
//        },
//        child: Text(
//          "CANCEL",
//          style: TextStyle(
//            color: primaryHighlight,
//          ),
//        ),
//      ),
//      willDisplayWidget: Column(
//        children: [
//          FlatButton(
//            onPressed: () {
//              _onImageButtonPressed(ImageSource.gallery);
//              Navigator.of(context, rootNavigator: true).pop();
//            },
//            child: Row(
//              children: [
//                Padding(
//                  padding: EdgeInsets.only(top: 15, right: 15, bottom: 15),
//                  child: const Icon(
//                    Icons.photo_library,
//                    color: secondaryHighlight,
//                  ),
//                ),
//                Text(
//                  'From Gallery',
//                  style: TextStyle(color: primaryHighlight, fontSize: 14),
//                ),
//              ],
//            ),
//          ),
//          FlatButton(
//            onPressed: () {
//              _onImageButtonPressed(ImageSource.camera);
//              Navigator.of(context, rootNavigator: true).pop();
//            },
//            child: Row(
//              children: [
//                Padding(
//                  padding: EdgeInsets.only(top: 15, right: 15, bottom: 15),
//                  child: const Icon(
//                    Icons.camera_alt,
//                    color: secondaryHighlight,
//                  ),
//                ),
//                Text(
//                  'From Camera',
//                  style: TextStyle(
//                    color: primaryHighlight,
//                    fontSize: 14,
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ],
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Share a Finesse'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  if (User.currentUser == null) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sorry, you must be logged in to create a post.',
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
                    return;
                  }
                  if (!_formKey.currentState.validate()) {
                    setState(() {
                      shouldValidate = true;
                    });
                  }
                  if (_formKey.currentState.validate()) {
                    Text eventName = Text(eventNameController.text);
                    Text location = Text(locationController.text);
                    Text description = Text(descriptionController.text);
                    Text duration = Text(durationController.text);
                    DateTime currTime = DateTime.now();

                    String imageString;
                    if (_image == null) {
                      imageString = '';
                    } else {
                      imageString = base64Encode(_image.readAsBytesSync());
                    }

                    Finesse newFinesse;
                    if (isOngoing) {
                      newFinesse = Finesse.finesseAdd(
                        eventName.data,
                        description.data,
                        imageString,
                        location.data,
                        duration.data,
                        _type,
                        currTime,
                      );
                    } else {
                      DateTime start = _startDate.add(
                        Duration(
                          hours: _startTime.hour,
                          minutes: _startTime.minute,
                        ),
                      );
                      DateTime end = _endDate?.add(
                        Duration(
                          hours: _endTime.hour,
                          minutes: _endTime.minute,
                        ),
                      );
                      if (end?.isBefore(start) ?? false) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "The end date can't be before the start date",
                              style: TextStyle(
                                color: secondaryHighlight,
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      if (start.isBefore(
                          DateTime.now().add(Duration(minutes: 15)))) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                'Future events must start in 15 minutes or more.',
                                style: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              action: SnackBarAction(
                                label: 'SWITCH TO ONGOING',
                                onPressed: () {
                                  setState(() {
                                    isOngoing = true;
                                  });
                                },
                              )),
                        );
                        return;
                      }
                      newFinesse = Finesse.future(
                        eventName.data,
                        description.data,
                        imageString,
                        location.data,
                        _type,
                        start,
                        endTime: end,
                        repetition: selectedRepetition,
                      );
                    }
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sharing Finesse',
                          style: TextStyle(
                            color: secondaryHighlight,
                          ),
                        ),
                      ),
                    );
                    String res = await addFinesse(newFinesse, isOngoing);
                    // could exploit the fact that id is sequential-ish
                    String newId = jsonDecode(res)['id'];
                    User.currentUser.upvoted.add(newId);
                    User.currentUser.subscriptions.add(newId);
                    if (User.currentUser.notifications) {
                      firebaseMessaging.subscribeToTopic(newId);
                    }
                    await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(
                                initialIndex: isOngoing ? 0 : 1,
                              )),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: primaryBackground,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: secondaryBackground,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 15, bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.title,
                              color: secondaryHighlight,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              autovalidate: shouldValidate,
                              key: Key('name'),
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                color: primaryHighlight,
                              ),
                              controller: eventNameController,
                              decoration: const InputDecoration(
                                labelText: "Title",
                                labelStyle: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.location_on,
                              color: secondaryHighlight,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              autovalidate: shouldValidate,
                              key: Key('location'),
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                color: primaryHighlight,
                              ),
                              controller: locationController,
                              decoration: const InputDecoration(
                                labelText: "Location",
                                labelStyle: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.short_text,
                              color: secondaryHighlight,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              key: Key('description'),
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                color: primaryHighlight,
                              ),
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: "Description",
                                labelStyle: TextStyle(
                                  color: secondaryHighlight,
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: isOngoing
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: isOngoing
                                ? const EdgeInsets.only(right: 10)
                                : const EdgeInsets.only(top: 12, right: 10),
                            child: Icon(
                              Icons.calendar_today,
                              color: secondaryHighlight,
                            ),
                          ),
                          if (isOngoing)
                            Expanded(
                              child: TextFormField(
                                key: Key('duration'),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: TextStyle(
                                  color: primaryHighlight,
                                ),
                                controller: durationController,
                                decoration: const InputDecoration(
                                  labelText: "Duration",
                                  labelStyle: TextStyle(
                                    color: secondaryHighlight,
                                  ),
                                ),
                                validator: (value) {
                                  return null;
                                },
                              ),
                            )
                          else
                            Expanded(
                              child: TimeEntry(
                                onSelectStartDate: (date) {
                                  setState(() => _startDate = date);
                                },
                                onSelectStartTime: (time) {
                                  setState(() => _startTime = time);
                                },
                                onSelectEndDate: (date) {
                                  setState(() => _endDate = date);
                                },
                                onSelectEndTime: (time) {
                                  setState(() => _endTime = time);
                                },
                                onSelectRepetition: (rep) {
                                  setState(() => selectedRepetition = rep);
                                },
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.image,
                                color: secondaryHighlight,
                              ),
                            ),
                            if (_image != null)
                              Container(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  child: Image.file(
                                    _image,
                                    height: 240,
                                  ),
                                  onTap: () async {
                                    File img = await uploadImagePopup(context);
                                    setState(() {
                                      if (img != null) _image = img;
                                    });
                                  },
                                ),
                              )
                            else
                              SizedBox(
                                height: 25,
                                child: OutlineButton(
                                  borderSide:
                                      BorderSide(color: secondaryHighlight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'Add image',
                                    style: TextStyle(
                                      color: secondaryHighlight,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  key: Key("Upload"),
                                  onPressed: () async {
                                    File img = await uploadImagePopup(context);
                                    setState(() {
                                      if (img != null) _image = img;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
