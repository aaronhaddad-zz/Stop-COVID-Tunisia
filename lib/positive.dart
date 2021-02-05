import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/app_in.dart';
import 'package:stop_covid/confirmation_box.dart';
import 'package:stop_covid/database/macdb.dart';
import 'package:stop_covid/loading.dart';
import 'package:stop_covid/user_positive.dart';

import 'database/initdb.dart';

class PositiveUser extends StatefulWidget {
  String email;
  String uid;
  PositiveUser(this.email, this.uid);

  @override
  _PositiveUserState createState() => _PositiveUserState();
}

PageController _pageController = PageController(
  initialPage: 0,
);

class _PositiveUserState extends State<PositiveUser> {
  final dbHelper = Initdb.instance;
  final macdbHelper = Macdb.instance;
  String key;
  String firstName, lastName;
  int numOfInformed = 0;

  final RoundedLoadingButtonController _controller =
      new RoundedLoadingButtonController();

  Future keyRetrieve() async {
    key = await dbHelper.pushkeyDb();
    numOfInformed = await macdbHelper.queryRowCount();
    setState(() {
      numOfInformed = numOfInformed;
    });
  }

  Future getFirstName() async {
    firstName = await dbHelper.firstNameDb();
    setState(() {
      firstName = firstName;
    });
  }

  Future getLastName() async {
    lastName = await dbHelper.lastNameDb();
    setState(() {
      lastName = lastName;
    });
  }

  String userMac;
  Future getMac() async {
    userMac = await dbHelper.mac();
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.columninfected: 0,
      Initdb.pushkey: '',
    };
    final rowsAffected = await dbHelper.update(row);
    dbHelper.dbContent();
  }

  void _notSuspected() async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.suspectedColumn: '0',
    };
    final rowsAffected = await dbHelper.update(row);
    dbHelper.dbContent();
  }

  @override
  void initState() {
    super.initState();
    keyRetrieve();
    getFirstName();
    getLastName();
    getMac();
    if (firstName == null) {
      setState(() {
        firstName = widget.email;
        lastName = '';
      });
    }
    FlutterLocalNotificationsPlugin().cancel(3);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Positif',
      home: Scaffold(
        backgroundColor: Color(0xff181a20),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xff181a20),
          title: Text(
            'Stop COVID (Positif)',
            style: TextStyle(
              color: Colors.redAccent,
              fontFamily: 'Poppins',
              fontSize: MediaQuery.of(context).textScaleFactor * 18.0,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).textScaleFactor * 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPositive(
                        firstName,
                        lastName,
                        widget.email,
                        userMac,
                        widget.uid,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: MediaQuery.of(context).textScaleFactor * 22.0,
                ),
              ),
            ),
          ],
        ),
        body: PageView(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          children: [
            Scaffold(
              bottomNavigationBar: BottomAppBar(
                elevation: 0,
                color: Color(0xff),
                child: Container(
                  width: 60,
                  height: 60.0,
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).textScaleFactor * 20.0,
                      right: MediaQuery.of(context).textScaleFactor * 20.0),
                  child: FloatingActionButton(
                    backgroundColor: Color(0xff246bfd),
                    onPressed: () {
                      _pageController.nextPage(
                          duration: new Duration(seconds: 1),
                          curve: Curves.fastLinearToSlowEaseIn);
                    },
                    child: Icon(Icons.navigate_next),
                  ),
                ),
              ),
              backgroundColor: Color(0xff),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).textScaleFactor * 20.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).textScaleFactor * 25.0),
                    child: Text(
                      'Salut,\n' + firstName + ' ' + lastName + ' 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).textScaleFactor * 22.0,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                    top: MediaQuery.of(context).textScaleFactor * 5.0,
                  )),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 30.0)),
                  Center(
                    child: Text(
                      'Vous êtes positif au COVID19',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: MediaQuery.of(context).textScaleFactor * 15.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 30.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 130.0,
                        decoration: BoxDecoration(
                          color: Color(0xff262a34),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).textScaleFactor *
                                      10.0),
                              child: Text(
                                numOfInformed.toString(),
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          22.0,
                                  fontFamily: 'Raleway',
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff84c36e),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).textScaleFactor *
                                      10.0,
                                  left: MediaQuery.of(context).textScaleFactor *
                                      10.0,
                                  right:
                                      MediaQuery.of(context).textScaleFactor *
                                          10.0),
                              child: Text(
                                'Pérsonne(s) ont été informés grâce à vous!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xfffbfbfb),
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            13.0,
                                    letterSpacing: 1.0,
                                    fontFamily: 'Poppins'),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).textScaleFactor *
                                      20.0,
                                  right:
                                      MediaQuery.of(context).textScaleFactor *
                                          20.0,
                                  top: MediaQuery.of(context).textScaleFactor *
                                      10.0),
                              child: Text(
                                'Vous protéger c\'est bien, protéger les autres c\'est mieux!',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Color(0xff515563),
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          11.0,
                                  fontFamily: 'Raleway',
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 30.0)),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60.0,
                      height: MediaQuery.of(context).textScaleFactor * 50.0,
                      child: RoundedLoadingButton(
                        color: Color(0xff92cf7a),
                        controller: _controller,
                        width: MediaQuery.of(context).size.width - 200.0,
                        onPressed: () async {
                          confirmationBox('Vous confirmez?', context, () async {
                            loading(
                                context,
                                SpinKitFoldingCube(
                                  color: Colors.white,
                                  size: 50.0,
                                ));
                            for (int i = 0; i <= numOfInformed + 1; i++) {
                              macdbHelper.delete(i);
                            }
                            keyRetrieve();
                            await FirebaseDatabase.instance
                                .reference()
                                .child(key)
                                .remove();
                            _update();
                            _notSuspected();

                            return Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AppIn(widget.email, widget.uid)),
                                (route) => false);
                          }, 'Oui', 'Non');
                        },
                        child: Text(
                          'Je ne suis plus positif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 14.0,
                            fontFamily: 'Raleway',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xff181a20),
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Les gestes barrières',
                  style: TextStyle(
                    color: Color(0xffff9a76),
                    fontFamily: 'Poppins',
                    fontSize: MediaQuery.of(context).textScaleFactor * 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              backgroundColor: Color(0xff),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BottomAppBar(
                    elevation: 0,
                    color: Color(0xff),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).textScaleFactor * 20.0,
                          left: MediaQuery.of(context).textScaleFactor * 20.0),
                      child: FloatingActionButton(
                        backgroundColor: Color(0xff246bfd),
                        onPressed: () {
                          _pageController.previousPage(
                              duration: new Duration(seconds: 1),
                              curve: Curves.fastLinearToSlowEaseIn);
                        },
                        child: Icon(Icons.navigate_before),
                      ),
                    ),
                  ),
                  BottomAppBar(
                    elevation: 0,
                    color: Color(0xff),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).textScaleFactor * 20.0,
                          right: MediaQuery.of(context).textScaleFactor * 20.0),
                      child: FloatingActionButton(
                        backgroundColor: Color(0xff246bfd),
                        onPressed: () {
                          _pageController.animateToPage(0,
                              duration: new Duration(seconds: 1),
                              curve: Curves.fastLinearToSlowEaseIn);
                        },
                        child: Icon(
                          Icons.home,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 20.0)),
                  GestureDetector(
                    onTap: () {},
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: Color(0xff262a34),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                            ),
                            Icon(
                              Icons.meeting_room_outlined,
                              size:
                                  MediaQuery.of(context).textScaleFactor * 60.0,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).textScaleFactor *
                                          10.0),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Enfermez-vous!\nseul!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 20.0)),
                  GestureDetector(
                    onTap: () {},
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 60.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: Color(0xff262a34),
                          borderRadius: BorderRadius.all(Radius.circular(
                              MediaQuery.of(context).textScaleFactor * 15.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                            ),
                            Icon(
                              Icons.medical_services,
                              size:
                                  MediaQuery.of(context).textScaleFactor * 60.0,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).textScaleFactor *
                                          10.0),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Rêstez en contact\navec votre medecin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlutterLocalNotificationPlugin {}
