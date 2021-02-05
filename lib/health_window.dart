import 'package:flutter/material.dart';

healthWindow(
    BuildContext context, bool isSuspected, String firstName, String text) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Color(0xff181a20),
          content: Container(
            width: MediaQuery.of(context).size.width - 100.0,
            height: MediaQuery.of(context).size.height / 1.2,
            color: Color(0xff181a20),
            child: Scaffold(
              backgroundColor: Color(0xff),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.all(8.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.keyboard_backspace,
                    color: Colors.white,
                  ),
                ),
              ),
              body: Center(
                child: Container(
                  color: Color(0xff),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Image.asset(
                          'assets/images/doctor.png',
                          width: 150.0,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Container(
                          height: 200.0,
                          color: (isSuspected) ? Colors.red : Colors.green,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '$firstName, $text',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: MediaQuery.textScaleFactorOf(
                                              context) *
                                          16.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Raleway',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '*N\'oubliez pas de toujours appliquer les gêstes barrières et de minimiser le contact avec les gens',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: MediaQuery.textScaleFactorOf(
                                              context) *
                                          14.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 8.0, right: 8.0),
                        child: Text(
                          'Notification en cas de contact:',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.textScaleFactorOf(context) * 18.0,
                            fontFamily: 'Poppins',
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 8.0, right: 8.0),
                        child: Text(
                          'Dans le cas où Stop COVID détécte que vous étiez en contact avec une personne positive au COVID19, une notification vous sera envoyée immédiattement',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.textScaleFactorOf(context) * 12.0,
                            fontFamily: 'Poppins',
                            color: Colors.white54,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
