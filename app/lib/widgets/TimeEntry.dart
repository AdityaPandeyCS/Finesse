import 'package:finesse_nation/Finesse.dart';
import 'package:finesse_nation/Styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeEntry extends StatefulWidget {
  final void Function(DateTime) onSelectStartDate;
  final void Function(TimeOfDay) onSelectStartTime;
  final void Function(DateTime) onSelectEndDate;
  final void Function(TimeOfDay) onSelectEndTime;
  final void Function(Repetition) onSelectRepetition;

  final DateTime initStartDate;
  final DateTime initEndDate;
  final TimeOfDay initStartTime;
  final TimeOfDay initEndTime;
  final Repetition initRepetition;

  TimeEntry({
    this.onSelectStartDate,
    this.onSelectStartTime,
    this.onSelectEndDate,
    this.onSelectEndTime,
    this.onSelectRepetition,
    this.initStartDate,
    this.initEndDate,
    this.initStartTime,
    this.initEndTime,
    this.initRepetition,
  });

  @override
  _TimeEntryState createState() => _TimeEntryState();
}

class _TimeEntryState extends State<TimeEntry> {
  DateTime _startDate;
  DateTime _endDate;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  bool _moreOptions;

  Repetition _selectedRepetition;
  static const Map<Repetition, String> _repetitionLabels = {
    Repetition.none: 'Does not repeat',
    Repetition.daily: 'Every day',
    Repetition.weekly: 'Every week',
    Repetition.monthly: 'Every month',
    Repetition.yearly: 'Every year',
  };

  @override
  void initState() {
    super.initState();

    if (widget.initStartDate != null) {
      _startDate = widget.initStartDate;
    } else {
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
    }

    _startTime = widget.initStartTime ?? TimeOfDay.now();

    _moreOptions = (widget.initEndDate != null) && (widget.initEndTime != null);

    if (_moreOptions) {
      _endDate = widget.initEndDate;
      _endTime = widget.initEndTime;
    }

    _selectedRepetition = widget.initRepetition ?? Repetition.none;
  }

  bool endIsBeforeStart() {
    if (!_moreOptions) return false;

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

    return end.isBefore(start);
  }

  Widget timeRow(String type) {
    bool isStart = type == 'Start';
    bool isInvalid = isStart && endIsBeforeStart();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            type,
            style: TextStyle(
              color: secondaryHighlight,
              fontSize: 12,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                DateTime tempDate = await showDatePicker(
                  context: context,
                  initialDate: isStart ? _startDate : _endDate,
                  firstDate: isStart ? DateTime.now() : _startDate,
                  lastDate: DateTime.now().add(
                    Duration(days: 365),
                  ),
                );
                if (tempDate == null) {
                  return;
                }
                setState(() {
                  if (isStart) {
                    _startDate = tempDate;
                    widget.onSelectStartDate(_startDate);
                    if (endIsBeforeStart()) {
                      // TODO: increment end date and time correctly
                      _endDate = tempDate;
                      widget.onSelectEndDate(_endDate);
                    }
                  } else {
                    _endDate = tempDate;
                    widget.onSelectEndDate(_endDate);
                  }
                });
              },
              child: Text(
                DateFormat('EEEE, MMM d, y')
                    .format(isStart ? _startDate : _endDate),
                style: TextStyle(
                  color: isInvalid ? Colors.red : primaryHighlight,
                  fontSize: 16,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                TimeOfDay tempTime = await showTimePicker(
                  context: context,
                  initialTime: isStart ? _startTime : _endTime,
                );
                if (tempTime == null) {
                  return;
                }
                setState(() {
                  if (isStart) {
                    _startTime = tempTime;
                    widget.onSelectStartTime(_startTime);
                  } else {
                    _endTime = tempTime;
                    widget.onSelectEndTime(_endTime);
                  }
                });
              },
              child: Text(
                isStart ? _startTime.format(context) : _endTime.format(context),
                style: TextStyle(
                  color: isInvalid ? Colors.red : primaryHighlight,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<void> showRepeatDialog() async {
    Repetition result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: Repetition.values.map((rep) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, rep);
                },
                child: Text(
                  _repetitionLabels[rep],
                  style: TextStyle(
                    fontWeight: (rep == _selectedRepetition)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          );
        });
    setState(() {
      _selectedRepetition = result ?? _selectedRepetition;
      widget.onSelectRepetition(_selectedRepetition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          timeRow('Start'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          GestureDetector(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    _moreOptions ? Icons.cancel : Icons.add_circle,
                    color: secondaryHighlight,
                    size: 20,
                  ),
                ),
                Text(
                  _moreOptions ? 'Cancel' : 'More options',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryHighlight,
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _moreOptions = !_moreOptions;
                //updateEnd();
                if (_moreOptions) {
                  _endDate = _startDate;
                  widget.onSelectEndDate(_endDate);

                  _endTime = TimeOfDay(
                    hour: _startTime.hour + 1,
                    minute: _startTime.minute,
                  ); // TODO: Won't be correct if time after 11pm
                  widget.onSelectEndTime(_endTime);
                } else {
                  _endDate = null;
                  _endTime = null;
                }

                _selectedRepetition = Repetition.none;
                widget.onSelectRepetition(_selectedRepetition);
              });
            },
          ),
          if (_moreOptions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: timeRow('End'),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Repeat',
                        style: TextStyle(
                          color: secondaryHighlight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      child: Text(
                        _repetitionLabels[_selectedRepetition],
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryHighlight,
                        ),
                      ),
                      onTap: showRepeatDialog,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
