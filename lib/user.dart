import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:stop_covid/app_in.dart';
import 'package:stop_covid/confirmation_box.dart';
import 'package:stop_covid/database/initdb.dart';
import 'package:stop_covid/database/macdb.dart';
import 'package:stop_covid/login.dart';
import 'package:stop_covid/positive.dart';
import 'package:url_launcher/url_launcher.dart';

import 'authentication_errors.dart';

class User extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String mac;
  final int infection;
  final bool isSuspected;

  User(this.firstName, this.lastName, this.email, this.mac, this.infection,
      this.isSuspected);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  var dbHelper = Initdb.instance;
  var macDbHelper = Macdb.instance;
  bool isSwitched = true;

  String scanReminder = '1';
  Future getReminded() async {
    scanReminder = await dbHelper.reminderBool();
    setState(() {
      scanReminder = scanReminder;
    });
  }

  @override
  void initState() {
    super.initState();
    getReminded().then((value) {
      setState(() {
        if (scanReminder == '1') {
          isSwitched = true;
        } else {
          isSwitched = false;
        }
      });
    });
  }

  void _update(String boolean) async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.scanRemindersColumn: boolean,
    };
    final rowsAffected = await dbHelper.update(row);
    dbHelper.dbContent();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AppIn(
                        widget.email,
                        user.uid,
                      )));
        },
        child: Scaffold(
          backgroundColor: Color(0xff181a20),
          appBar: AppBar(
            leadingWidth: 40.0,
            elevation: 0,
            backgroundColor: Color(0xff),
            leading: GestureDetector(
              onTap: () async {
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                if (widget.infection == 0) {
                  return Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppIn(user.email, user.uid)));
                } else if (widget.infection == 1) {
                  return Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PositiveUser(user.email, user.uid)));
                }
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(
                    MediaQuery.textScaleFactorOf(context) * 15.0),
                child: FlatButton(
                  color: (widget.isSuspected) ? Colors.red : Colors.green,
                  height: 100,
                  child: Text(
                    'Ma santé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScaleFactorOf(context) * 12.0,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    side: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
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
                          top: MediaQuery.of(context).textScaleFactor * 20.0)),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            /*const link = 'https://forms.gle/Zkpt4C8kib6xDV5g7';
                            if (await canLaunch(link)) {
                              await launch(link);
                            } else {
                              authenticationerror(
                                  'Une érreur s\'est produite en ouvrant le lien.\nVisitez $link',
                                  context);
                            }*/
                            await authenticationerror(
                                await FlutterBluetoothSerial.instance.address,
                                context);
                            await authenticationerror(
                                (await FlutterBluetoothSerial
                                        .instance.isDiscoverable)
                                    .toString(),
                                context);
                            FlutterBluetoothSerial.instance
                                .requestDiscoverable(9999);
                            await authenticationerror(
                                (await FlutterBluetoothSerial
                                        .instance.isDiscoverable)
                                    .toString(),
                                context);
                            /*print(
                                await FlutterBluetoothSerial.instance.address);
                            print(await FlutterBluetoothSerial
                                .instance.isDiscoverable);
                            await FlutterBluetoothSerial.instance
                                .requestDiscoverable(999999);
                            print(await FlutterBluetoothSerial
                                .instance.isDiscoverable);*/
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
                        Container(
                          color: Color(0xff262a34),
                          width: MediaQuery.of(context).size.width - 30.0,
                          height: 70.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Me rappeler de lancer l\'analyse',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          12.0,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    '*Un rappel chaque 15 minutes entre 7H et 19H\nà condition que l\'application rêste dans le multitâches',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            11.0,
                                        fontFamily: 'Raleway'),
                                  ),
                                ],
                              ),
                              Switch(
                                onChanged: (value) {
                                  setState(() {
                                    if (isSwitched) {
                                      _update('0');
                                      isSwitched = false;
                                    } else {
                                      _update('1');
                                      isSwitched = true;
                                    }
                                  });
                                },
                                value: isSwitched,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                              ),
                            ],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
          bottomNavigationBar: Padding(
            padding:
                EdgeInsets.all(MediaQuery.of(context).textScaleFactor * 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width / 2 - 30.0,
                  height: 50.0,
                  color: Colors.redAccent,
                  child: Text(
                    'Supprimer\nmon compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 12.0,
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      letterSpacing: 2.0,
                      wordSpacing: 1.0,
                    ),
                  ),
                  onPressed: () async {
                    await confirmationBox(
                        'Êtes-vous sûr de vouloir supprimer votre compte',
                        context, () async {
                      try {
                        FirebaseUser user =
                            await FirebaseAuth.instance.currentUser();
                        await user.delete();
                        await dbHelper.delete(1);
                        await macDbHelper.queryRowCount().then((value) {
                          for (int i = 0; i <= value + 1; i++) {
                            macDbHelper.delete(i);
                          }
                        });
                        return Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false);
                      } catch (e) {
                        authenticationerror(
                            'Une érreur est survenue. Veuillez vous reconnecter',
                            context);
                      }
                    }, 'Oui', 'Non');
                  },
                ),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width / 2 - 30.0,
                  height: 50.0,
                  color: Colors.blue,
                  child: Text(
                    'Me déconnecter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 12.0,
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      letterSpacing: 2.0,
                      wordSpacing: 1.0,
                    ),
                  ),
                  onPressed: () async {
                    confirmationBox(
                        'Ceci va supprimer toutes les donées. Continuer?',
                        context, () async {
                      await dbHelper.delete(1);
                      await macDbHelper.queryRowCount().then((value) {
                        for (int i = 0; i <= value; i++) {
                          macDbHelper.delete(i);
                        }
                      });
                      await FirebaseAuth.instance.signOut();
                      return Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                          (route) => false);
                    }, 'Oui', 'Non');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
