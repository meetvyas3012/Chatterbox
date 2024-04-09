import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dialogs
{
  static void show_snackbar(BuildContext context,String text)
  {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: Colors.blue.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        )
    );
  }

  static void show_progress_bar(BuildContext context)
  {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator(),)
    );
  }
}