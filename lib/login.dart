import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/authentication_errors.dart';
import 'package:stop_covid/register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database/initdb.dart';
import 'name.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Detecting if the user is already signed in
  Future<FirebaseUser> logInAutomatically() async {
    return await FirebaseAuth.instance.currentUser();
  }

  final RoundedLoadingButtonController _controller =
      new RoundedLoadingButtonController();

  //Setting up Firebase Auth
  FirebaseAuth auth = FirebaseAuth.instance;

  //TextEditing controllers
  TextEditingController edEmail = new TextEditingController();
  TextEditingController edPassword = new TextEditingController();

  bool _visiblePassword = false;
  var iconShow = Icons.visibility_off;

  @override
  void initState() {
    super.initState();
    FlutterLocalNotificationsPlugin().cancel(3);
  }

  String address;
  Future getAddress() async {
    address = await FlutterBluetoothSerial.instance.address;
    await FlutterBluetoothSerial.instance.requestDiscoverable(9999);
  }

  final dbHelper = Initdb.instance;

  void _insert(
      int uid,
      String email,
      String macAddress,
      String userId,
      String firstTimeIn,
      String scanReminder,
      String suspected,
      String infection) async {
    // row to insert
    Map<String, dynamic> row = {
      Initdb.columnId: uid,
      Initdb.columnemail: email,
      Initdb.columnmac: macAddress,
      Initdb.columnuserId: userId,
      Initdb.firstTimeInColumn: firstTimeIn,
      Initdb.scanRemindersColumn: scanReminder,
      Initdb.columninfected: infection,
      Initdb.suspectedColumn: suspected,
    };
    final id = await dbHelper.insert(row);
  }

  loginFunction() async {
    _controller.start();
    if (edEmail.text.isEmpty || edPassword.text.isEmpty) {
      if (edEmail.text.isEmpty && edPassword.text.isEmpty) {
        _controller.error();
        await authenticationerror(
            'Veuillez entrer votre email et votre mote de passe', context);
        await new Future.delayed(new Duration(seconds: 1));
        _controller.reset();
      } else if (edPassword.text.isEmpty) {
        _controller.error();
        await authenticationerror(
            'Veuillez entrer votre mot de passe', context);
        await new Future.delayed(new Duration(seconds: 1));
        _controller.reset();
      } else if (edEmail.text.isEmpty) {
        _controller.error();
        await authenticationerror('Veuilez entrer votre email', context);
        await new Future.delayed(new Duration(seconds: 1));
        _controller.reset();
      }
    } else {
      try {
        FirebaseUser user = (await auth.signInWithEmailAndPassword(
                email: edEmail.text, password: edPassword.text))
            .user;
        if (user != null) {
          await getAddress();
          print(address);
          _insert(1, user.email, address, user.uid, '1', '1', '0', '0');
          _controller.success();
          await new Future.delayed(new Duration(seconds: 1));
          return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Name(user.email, user.uid),
              ));
        }
      } catch (e) {
        _controller.error();
        await new Future.delayed(new Duration(seconds: 1));
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
            _controller.error();
            edEmail.text = "";
            edPassword.text = "";
            authenticationerror('L\'email entré est invalide!', context);
            _controller.reset();
            break;
          case 'ERROR_USER_NOT_FOUND':
            _controller.error();
            edEmail.text = "";
            edPassword.text = "";
            authenticationerror(
                'Ces infos ne corréspondent à aucun utilisateur', context);
            _controller.reset();
            break;
          case 'ERROR_WRONG_PASSWORD':
            _controller.error();
            edEmail.text = "";
            edPassword.text = "";
            authenticationerror('Le mot de passe entré est erroné', context);
            _controller.reset();
            break;
          case 'ERROR_NETWORK_REQUEST_FAILED':
            _controller.error();
            authenticationerror('Veuillez vous connecter à internet', context);
            _controller.reset();
            edEmail.text = edPassword.text = '';
            break;
          default:
            _controller.error();
            edEmail.text = "";
            edPassword.text = "";
            authenticationerror(
                'Une erreur s\'est produite. Veuillez réessayer', context);
            _controller.reset();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: IntrinsicHeight(
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Stop COVID',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 30.0,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'Se connecter',
                          maxLines: 1,
                          style: TextStyle(
                              color: Color(0xff9efedd),
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 20.0,
                              fontFamily: 'Raleway',
                              letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  Center(
                      child: Container(
                    width: MediaQuery.of(context).size.width - 60.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                            ),
                            suffixIcon: Icon(
                              Icons.mail,
                              color: Colors.white,
                            ),
                            focusedBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(
                                color: Color(0xffffd051),
                              ),
                            ),
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          controller: edEmail,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 25.0,
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 0),
                        ),
                        TextFormField(
                          onFieldSubmitted: (term) {
                            loginFunction();
                          },
                          textInputAction: TextInputAction.go,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          obscureText: (_visiblePassword) ? false : true,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                iconShow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_visiblePassword) {
                                    _visiblePassword = false;
                                    iconShow = Icons.visibility_off;
                                  } else {
                                    _visiblePassword = true;
                                    iconShow = Icons.visibility;
                                  }
                                });
                              },
                            ),
                            focusedBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(
                                color: Color(0xffffd051),
                              ),
                            ),
                            hintText: 'Mot de passe',
                            hintStyle: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          controller: edPassword,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 25.0,
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 0),
                        ),
                        ButtonTheme(
                          minWidth: 200.0,
                          height: MediaQuery.of(context).size.width - 20.0,
                          child: RoundedLoadingButton(
                            borderRadius: 10.0,
                            controller: _controller,
                            onPressed: () {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              loginFunction();
                            },
                            color: Color(0xffff968e),
                            child: Text(
                              'Me connecter!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 10.0,
                              MediaQuery.of(context).textScaleFactor * 0,
                              MediaQuery.of(context).textScaleFactor * 0),
                        ),
                        FlatButton(
                          onPressed: () {},
                          child: Text(
                            'Vous avez un problème?',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ));
                    },
                    child: Text(
                      'Nouveau ici? Inscrivez-vous!',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
