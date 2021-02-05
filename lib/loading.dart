import 'package:flutter/material.dart';

loading(BuildContext context, Widget widget) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 0.0,
          backgroundColor: Color(0xff),
          content: Scaffold(
            backgroundColor: Color(0xff),
            body: WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 100.0,
                  height: MediaQuery.of(context).size.height - 300.0,
                  color: Color(0xff),
                  child: Center(
                    child: widget,
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
