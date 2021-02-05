import 'package:flutter/material.dart';
import 'package:stop_covid/database/initdb.dart';
import 'package:stop_covid/database/macdb.dart';
import 'package:url_launcher/url_launcher.dart';

import 'authentication_errors.dart';

class UserPositive extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String mac;
  final String uid;
  UserPositive(this.firstName, this.lastName, this.email, this.mac, this.uid);

  @override
  _UserPositiveState createState() => _UserPositiveState();
}

class _UserPositiveState extends State<UserPositive> {
  var dbHelper = Initdb.instance;
  var macDbHelper = Macdb.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff181a20),
        appBar: AppBar(
          leadingWidth: 40.0,
          elevation: 0,
          backgroundColor: Color(0xff),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).textScaleFactor * 20.0)),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      backgroundColor: Color(0xffff968e),
                      radius: 40.0,
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).textScaleFactor * 40.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).textScaleFactor * 10.0)),
                Center(
                  child: Text(
                    widget.firstName + ' ' + widget.lastName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      letterSpacing: 1.0,
                      fontSize: MediaQuery.of(context).textScaleFactor * 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).textScaleFactor * 5.0)),
                Center(
                  child: Text(
                    widget.email,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      letterSpacing: 1.0,
                      fontSize: MediaQuery.of(context).textScaleFactor * 13.0,
                      color: Color(0xff9cffdc),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).textScaleFactor * 5.0)),
                Center(
                  child: Text(
                    widget.mac,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      letterSpacing: 1.0,
                      fontSize: MediaQuery.of(context).textScaleFactor * 13.0,
                      color: Color(0xff9cffdc),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).textScaleFactor * 30.0)),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      ),
                      GestureDetector(
                        onTap: () async {
                          const link = 'https://forms.gle/Zkpt4C8kib6xDV5g7';
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            authenticationerror(
                                'Une érreur s\'est produite en ouvrant le lien.\nVisitez $link',
                                context);
                          }
                        },
                        child: Container(
                          color: Color(0xff262a34),
                          width: MediaQuery.of(context).size.width - 30.0,
                          height: 50.0,
                          child: Center(
                            child: AppBar(
                              elevation: 1,
                              backgroundColor: Color(0xff262a34),
                              centerTitle: true,
                              leading: Icon(
                                Icons.bug_report,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Signaler un bug',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          13.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      ),
                      GestureDetector(
                        onTap: () async {
                          const link =
                              'https://aaronhaddad.github.io/scovid/how-to.html';
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            authenticationerror('Visiter $link', context);
                          }
                        },
                        child: Container(
                          color: Color(0xff262a34),
                          width: MediaQuery.of(context).size.width - 30.0,
                          height: 70.0,
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.textScaleFactorOf(context) * 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.contact_support_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Comment utiliser Stop COVID?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.textScaleFactorOf(
                                              context) *
                                          12.0,
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
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      ),
                      GestureDetector(
                        onTap: () async {
                          const link =
                              'mailto:contact@aaronhaddad.tech?subject=Contact Stop COVID Android';
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            authenticationerror(
                                'Veuillez envoyer un email à contact@aaronhaddad.tech',
                                context);
                          }
                        },
                        child: Container(
                          color: Color(0xff262a34),
                          width: MediaQuery.of(context).size.width - 30.0,
                          height: 70.0,
                          child: Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.textScaleFactorOf(context) * 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.question_answer,
                                    color: Colors.white,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Contacter Stop COVID',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.textScaleFactorOf(
                                              context) *
                                          12.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
