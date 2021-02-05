import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stop_covid/app_in.dart';
import 'package:stop_covid/database/initdb.dart';
import 'package:url_launcher/url_launcher.dart';

import 'authentication_errors.dart';

class Name extends StatefulWidget {
  final String email;
  final String uid;
  Name(this.email, this.uid);

  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<Name> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController famNameController = new TextEditingController();
  bool checked = false;

  final dbHelper = Initdb.instance;

  @override
  Widget build(BuildContext context) {
    void _update(String firstName, String lastName) async {
      // row to update
      Map<String, dynamic> row = {
        Initdb.columnId: 1,
        Initdb.firstNameColumn: firstName,
        Initdb.lastNameColumn: lastName,
        Initdb.dateColumn: DateTime.now().year.toString() +
            '-' +
            DateTime.now().month.toString() +
            '-' +
            DateTime.now().day.toString()
      };
      final rowsAffected = await dbHelper.update(row);
      dbHelper.dbContent();
    }

    gettingIn() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      if (nameController.text.isEmpty && famNameController.text.isEmpty) {
        authenticationerror(
            'Veuillez entrer votre prénom et votre nom', context);
      } else if (nameController.text.isEmpty) {
        authenticationerror('Veuillez entrer votre prénom', context);
      } else if (famNameController.text.isEmpty) {
        authenticationerror('Veuillez entrer votre nom', context);
      } else if (!checked) {
        authenticationerror(
            'Il faut accepter les conditions d\'utilisation', context);
      } else {
        _update(
            nameController.text.toString(), famNameController.text.toString());
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AppIn(widget.email, widget.uid),
          ),
        );
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).textScaleFactor * 50.0)),
              Text(
                'Stop COVID',
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).textScaleFactor * 30.0,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                //'Adresse MAC Bluetooth',
                'Une dérnière chose',
                maxLines: 1,
                style: TextStyle(
                  color: Color(0xffffd051),
                  fontSize: MediaQuery.of(context).textScaleFactor * 20.0,
                  fontFamily: 'Poppins',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.textScaleFactorOf(context) * 12.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 30.0,
                  child: TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                      fontFamily: 'Raleway',
                      letterSpacing: 1.0,
                    ),
                    decoration: InputDecoration(
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Color(0xffffd051),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                      hintText: 'Votre prénom',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                        fontFamily: 'Raleway',
                        letterSpacing: 1,
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.textScaleFactorOf(context) * 12.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 30.0,
                  child: TextFormField(
                    controller: famNameController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                      fontFamily: 'Raleway',
                      letterSpacing: 1.0,
                    ),
                    decoration: InputDecoration(
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Color(0xffffd051),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.text_fields,
                        color: Colors.white,
                      ),
                      hintText: 'Votre nom',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                        fontFamily: 'Raleway',
                        letterSpacing: 1,
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (term) {
                      gettingIn();
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.textScaleFactorOf(context) * 15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: Colors.redAccent,
                        ),
                        child: Checkbox(
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked) {
                                checked = true;
                              } else {
                                checked = false;
                              }
                            });
                          },
                          value: checked,
                          activeColor: Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!checked) {
                              checked = true;
                            } else {
                              checked = false;
                            }
                          });
                        },
                        child: Text(
                          'J\'accepte les conditions d\'utilisation\nde Stop COVID',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: (checked) ? Colors.green : Colors.white,
                            fontSize:
                                MediaQuery.textScaleFactorOf(context) * 12.0,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.textScaleFactorOf(context) * 10.0,
                ),
                child: Container(
                  width: 200.0,
                  height: 40.0,
                  child: FlatButton(
                    child: Text(
                      'Bienvenue ☺️',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onPressed: () {
                      gettingIn();
                    },
                    color: Color(0xffff8989),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  const link =
                      'https://aaronhaddad.github.io/scovid/conditions.html';
                  if (await canLaunch(link)) {
                    await launch(link);
                  } else {
                    authenticationerror('Veuillez visiter $link', context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    'Lire les conditions d\'utilisation de Stop COVID',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
