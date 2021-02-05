import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/authentication_errors.dart';
import 'package:stop_covid/login.dart';
import 'package:url_launcher/url_launcher.dart';

class HowToUse extends StatefulWidget {
  @override
  _HowToUseState createState() => _HowToUseState();
}

class _HowToUseState extends State<HowToUse> {
  BluetoothState state;
  String email;
  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin().cancel(3);
  }

  RoundedLoadingButtonController _buttonController =
      new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: PageView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            children: [
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xfffff),
                  elevation: 0,
                  title: Text(
                    'Bienvenue dans Stop COVID! 👋',
                    style: TextStyle(
                      color: Color(0xff873794),
                      fontSize: MediaQuery.of(context).textScaleFactor * 16.0,
                      fontFamily: 'Raleway',
                      wordSpacing: 1.0,
                    ),
                  ),
                ),
                backgroundColor: Color(0xfffff),
                bottomNavigationBar: BottomAppBar(
                  elevation: 0,
                  color: Color(0xfffff),
                  child: Container(
                    height: 90.0,
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).textScaleFactor * 20.0),
                    child: RaisedButton(
                      onPressed: () {
                        _controller.nextPage(
                          curve: Curves.fastOutSlowIn,
                          duration: Duration(milliseconds: 600),
                        );
                      },
                      child: Text(
                        'Suivant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 16.0,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.0,
                        ),
                      ),
                      color: Color(0xffff5f2b),
                    ),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).textScaleFactor * 10.0,
                          left: MediaQuery.of(context).textScaleFactor * 10.0,
                          right: MediaQuery.of(context).textScaleFactor * 10.0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 30.0,
                          child: Text(
                            'Stop COVID est une application mobile 100% Tunisienne qui utilise le Bluetooth pour alérter les gens d\'un éventuel risque de contamination.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 16.0,
                              color: Color(0xffff6328),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/tutorial1.png',
                          width: (MediaQuery.of(context).size.width + 200.0) -
                              MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Scaffold(
                backgroundColor: Color(0xfffff),
                appBar: AppBar(
                  backgroundColor: Color(0xfffff),
                  elevation: 0,
                  title: Text(
                    'Comment ça marche?',
                    style: TextStyle(
                      color: Color(0xff873794),
                      fontSize: MediaQuery.of(context).textScaleFactor * 16.0,
                      fontFamily: 'Raleway',
                      wordSpacing: 1.0,
                    ),
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  elevation: 0,
                  color: Color(0xffff),
                  child: Container(
                    height: 90.0,
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).textScaleFactor * 20.0),
                    child: RaisedButton(
                      onPressed: () {
                        _controller.nextPage(
                          curve: Curves.fastOutSlowIn,
                          duration: Duration(milliseconds: 600),
                        );
                      },
                      child: Text(
                        'Suivant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 16.0,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.0,
                        ),
                      ),
                      color: Color(0xffff5f2b),
                    ),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 50.0,
                        child: Text(
                          'Le principe est simple! Allumez votre Bluetooth et GPS et Stop COVID s\'occupe du rêste!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 15.0,
                            color: Color(0xffff6328),
                            fontFamily: 'Raleway',
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/tutorial2.png',
                          height: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 30.0,
                        child: Text(
                          'Stop COVID scanne votre environnement et vous alerte en cas de contact avec un cas positive.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 14.0,
                            color: Color(0xffff6328),
                            fontFamily: 'Raleway',
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Color(0xfffff),
                    title: Text(
                      'Consignes d\'utilisation',
                      style: TextStyle(
                        color: Color(0xff873794),
                        fontFamily: 'Poppins',
                        fontSize: MediaQuery.of(context).textScaleFactor * 16.0,
                      ),
                    ),
                  ),
                  backgroundColor: Color(0xfffff),
                  body: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 20.0,
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: EdgeInsets.all(
                            MediaQuery.textScaleFactorOf(context) * 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).textScaleFactor *
                                          30.0,
                                  backgroundColor: Color(0xff181a20),
                                  child: Icon(
                                    Icons.gps_fixed_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Activez le GPS',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            16.0,
                                        fontFamily: 'Raleway',
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          200.0,
                                      child: Text(
                                        'Android requirt le GPS pour les applications qui utilisent Bluetooth',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .textScaleFactor *
                                              12.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).textScaleFactor *
                                            40.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 160.0,
                                  child: Column(
                                    children: [
                                      Text(
                                        'La bonne adresse Bluetooth',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .textScaleFactor *
                                              18.0,
                                          fontFamily: 'Raleway',
                                        ),
                                      ),
                                      Text(
                                        'Cette adresse est unique, et permet à Stop COVID d\'accomplir sa mission.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .textScaleFactor *
                                              12.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).textScaleFactor *
                                          30.0,
                                  backgroundColor: Color(0xff181a20),
                                  child: Icon(
                                    Icons.settings_bluetooth,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).textScaleFactor *
                                            40.0)),
                            RoundedLoadingButton(
                              controller: _buttonController,
                              onPressed: () async {
                                _buttonController.start();
                                const link =
                                    'https://aaronhaddad.github.io/scovid/how-to.html';
                                if (await canLaunch(link)) {
                                  _buttonController.success();
                                  await launch(link);
                                  _buttonController.reset();
                                } else {
                                  _buttonController.error();
                                  authenticationerror(
                                      'Une érreur s\'est produite en ouvrant le lien.\nVisitez https://aaronhaddad.github.io/scovid/how-to.html',
                                      context);
                                  _buttonController.reset();
                                }
                              },
                              color: Color(0xff181827),
                              child: Text(
                                'Pourquoi?',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          18.0,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    elevation: 0,
                    color: Color(0xfffff),
                    child: Container(
                      height: 90.0,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).textScaleFactor * 20.0),
                      child: RaisedButton(
                        onPressed: () {
                          FlutterBlue.instance.state.listen((state) {
                            if (state == BluetoothState.off) {
                              authenticationerror(
                                  'Veuillez activer le Bluetooth et le GPS!',
                                  context);
                            } else if (state == BluetoothState.on) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ));
                            }
                          });
                        },
                        child: Text(
                          'Allons-y!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 16.0,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.0,
                          ),
                        ),
                        color: Color(0xffff5f2b),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
