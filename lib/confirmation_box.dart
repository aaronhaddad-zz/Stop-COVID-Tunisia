import 'package:flutter/material.dart';

confirmationBox(
    String error, context, function(), String btn1Text, String btn2Text) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5.0,
          backgroundColor: Color(0xff262a34),
          content: Container(
            width: 200.0,
            height: 40.0,
            child: Center(
              child: Text(
                error,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).textScaleFactor * 12.0,
                  fontFamily: 'Raleway',
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          actions: [
            Container(
              width: 370.0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      minWidth: 100.0,
                      color: Color(0xfff03434),
                      onPressed: () {
                        function();
                      },
                      child: Text(
                        btn1Text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 12.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    ),
                    MaterialButton(
                      minWidth: 100.0,
                      color: Color(0xff2abb9b),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        btn2Text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      });
}
