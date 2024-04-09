

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyDateUtil
{
  static String get_last_message_time({ required BuildContext context,required String time,bool show_year=false})
  {
    final DateTime sent=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now=DateTime.now();

    if(now.day==sent.day && now.month==sent.month && now.year==sent.year)
      {
        return TimeOfDay.fromDateTime(sent).format(context);
      }

    return show_year
        ? "${sent.day} ${_get_month(sent)} ${sent.year}"
        : "${sent.day} ${_get_month(sent)}";
  }

  static String get_last_active_time(BuildContext context,String last_active)
  {
    final int i=int.tryParse(last_active) ?? -1;

    if (i==-1) return "Last seen not available";

    DateTime time=DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now=DateTime.now();

    if(now.day==time.day && now.month==time.month && now.year==time.year)
    {
      return "Last seen today at ${TimeOfDay.fromDateTime(time).format(context)}";
    }

    if ((now.difference(time).inHours/24).round()==1)
      {
        return "Last seen yesterday at ${TimeOfDay.fromDateTime(time).format(context)}";
      }

    return "Last seen on ${time.day} ${_get_month(time)} at ${TimeOfDay.fromDateTime(time).format(context)}";
  }

  static String get_message_time({required BuildContext context,required String time})
  {
    final DateTime sent=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now=DateTime.now();

    final formatted_time=TimeOfDay.fromDateTime(sent).format(context);
    if (sent.day==now.day && sent.month==now.month)
      {
        return formatted_time;
      }

    return
      (sent.year==now.year)
          ? "${formatted_time} ${_get_month(sent)}"
          : "${formatted_time} ${_get_month(sent)} ${sent.year}";
  }

  static String get_formatted_date({required BuildContext context,required String time})
  {
    final sent=DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(sent).format(context);
  }

  static String _get_month(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}