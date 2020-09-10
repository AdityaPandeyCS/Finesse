import 'package:flutter/material.dart';
import 'package:finesse_nation/Styles.dart';

/// Contains helper function to display a popup
class PopUpBox {
  /// Displays a [Dialog] containing filtering options.
  static Future showPopupBox(
      {BuildContext context,
      Widget willDisplayWidget,
      Widget button,
      String title = "Filter"}) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                color: primaryHighlight,
              ),
            ),
            backgroundColor: secondaryBackground,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                willDisplayWidget,
              ],
            ),
            actions: <Widget>[button],
          );
        });
  }
}
