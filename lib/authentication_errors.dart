import 'package:flutter/material.dart';

authenticationerror(String error, context) {
  return showDialog(
      context: context,
      barrierDismissible: true,
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
                child: RaisedButton(
                  color: Color(0xffc25fff),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: MediaQuery.of(context).textScaleFactor * 12.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      });
}
