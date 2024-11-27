import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
class AssociateMethods
{
  showSnackBarMsg(String msg, BuildContext cxt)
  {
    var snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(cxt).showSnackBar(snackBar);
  }
}