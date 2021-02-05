import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/authentication_errors.dart';
import 'package:stop_covid/login.dart';
import 'package:stop_covid/mac_address.dart';
import 'package:stop_covid/name.dart';

import 'database/initdb.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController email = new TextEditingController();
  final TextEditingController password = new TextEditingController();

  RoundedLoadingButtonController _buttonController =
      new RoundedLoadingButtonController();

  var passwordIcon = Icons.visibility_off;
  bool _visiblePassword = false;

  String address;
  Future getAddress() async {
    address = await FlutterBluetoothSerial.instance.address;
  }

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

  registrationFunction() async {
    _buttonController.start();
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email.text, password: password.text))
            .user;
        if (user != null) {
          _buttonController.success();
          await new Future.delayed(new Duration(seconds: 1));
          await getAddress();
          print(address);
          _insert(1, user.email, address, user.uid, '1', '1', '0', '0');
          return Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Name(user.email, user.uid)));
        }
      } catch (e) {
        _buttonController.error();
        switch (e.code) {
          case 'ERROR_INVALID_EMAIL':
            _buttonController.error();
            authenticationerror('Cet email est invalide', context);
            _buttonController.reset();
            email.text = password.text = '';
            break;
          case 'ERROR_EMAIL_ALREADY_IN_USE':
            _buttonController.error();
            authenticationerror('Cet email est dèja utilisé', context);
            _buttonController.reset();
            email.text = password.text = '';
            break;
          case 'ERROR_WEAK_PASSWORD':
            _buttonController.error();
            authenticationerror(
                'Le mot de passe doit avoir au moins 8 caractères', context);
            _buttonController.reset();
            email.text = password.text = '';
            break;
          case 'ERROR_NETWORK_REQUEST_FAILED':
            _buttonController.error();
            authenticationerror('Veuillez vous connecter à internet', context);
            _buttonController.reset();
            email.text = password.text = '';
            break;
          default:
            _buttonController.error();
            authenticationerror(
                'Une érreur s\'est produite. Veuillez réessayer', context);
            _buttonController.reset();
            email.text = password.text = '';
        }
      }
    } else {
      if (email.text.isEmpty && password.text.isEmpty) {
        _buttonController.error();
        await authenticationerror(
            'Veuillez entrer votre email et mot de passe', context);
        await Future.delayed(new Duration(seconds: 1));
        _buttonController.reset();
      } else if (email.text.isEmpty) {
        _buttonController.error();
        await authenticationerror('Veuillez entrer votre email', context);
        await Future.delayed(new Duration(seconds: 1));
        _buttonController.reset();
        email.text = password.text = '';
      } else if (password.text.isEmpty) {
        _buttonController.error();
        await authenticationerror('Veuillez entrer mot de passe', context);
        await Future.delayed(new Duration(seconds: 1));
        _buttonController.reset();
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
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
                          'S\'inscrire',
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
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          controller: email,
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
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0,
                              MediaQuery.of(context).textScaleFactor * 25.0,
                              0,
                              0),
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: (_visiblePassword) ? false : true,
                          textInputAction: TextInputAction.go,
                          onFieldSubmitted: (term) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            _buttonController.start();
                            registrationFunction();
                          },
                          controller: password,
                          maxLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordIcon,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_visiblePassword) {
                                    _visiblePassword = false;
                                    passwordIcon = Icons.visibility_off;
                                  } else if (!_visiblePassword) {
                                    _visiblePassword = true;
                                    passwordIcon = Icons.visibility;
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
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0,
                              MediaQuery.of(context).textScaleFactor * 25.0,
                              0,
                              0),
                        ),
                        RoundedLoadingButton(
                          borderRadius: 10.0,
                          color: Color(0xff8aca72),
                          controller: _buttonController,
                          child: Text(
                            'M\'inscrire!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            registrationFunction();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0,
                              MediaQuery.of(context).textScaleFactor * 25.0,
                              0,
                              0),
                        ),
                      ],
                    ),
                  )),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                    },
                    child: Text(
                      'Dèja inscrit? Connectez-vous!',
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
