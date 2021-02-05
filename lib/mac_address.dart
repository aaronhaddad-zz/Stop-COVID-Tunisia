import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/authentication_errors.dart';
import 'package:stop_covid/database/initdb.dart';
import 'package:stop_covid/find_mac.dart';
import 'package:stop_covid/name.dart';
import 'package:system_settings/system_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MacAddress extends StatefulWidget {
  final String email;
  final String userID;
  MacAddress(this.email, this.userID);

  @override
  _MacAddressState createState() => _MacAddressState();
}

final dbHelper = Initdb.instance;
final RoundedLoadingButtonController _controller =
    new RoundedLoadingButtonController();
String address;
Future getAddress() async {
  address = await FlutterBluetoothSerial.instance.address;
}

class _MacAddressState extends State<MacAddress> {
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

  TextEditingController mac01 = new TextEditingController();
  TextEditingController mac02 = new TextEditingController();
  TextEditingController mac03 = new TextEditingController();
  TextEditingController mac04 = new TextEditingController();
  TextEditingController mac05 = new TextEditingController();
  TextEditingController mac06 = new TextEditingController();
  String mac;

  void macCollect() async {
    if (mac01.text.isNotEmpty &&
        mac01.text.length == 2 &&
        mac02.text.isNotEmpty &&
        mac02.text.length == 2 &&
        mac03.text.isNotEmpty &&
        mac03.text.length == 2 &&
        mac04.text.isNotEmpty &&
        mac04.text.length == 2 &&
        mac05.text.isNotEmpty &&
        mac05.text.length == 2 &&
        mac06.text.isNotEmpty &&
        mac06.text.length == 2 &&
        mac01.text.toString()[0] != ' ' &&
        mac01.text.toString()[1] != ' ' &&
        mac02.text.toString()[0] != ' ' &&
        mac02.text.toString()[1] != ' ' &&
        mac03.text.toString()[0] != ' ' &&
        mac03.text.toString()[1] != ' ' &&
        mac04.text.toString()[0] != ' ' &&
        mac04.text.toString()[1] != ' ' &&
        mac05.text.toString()[0] != ' ' &&
        mac05.text.toString()[1] != ' ' &&
        mac06.text.toString()[0] != ' ' &&
        mac06.text.toString()[1] != ' ') {
      mac = mac01.text +
          ':' +
          mac02.text +
          ':' +
          mac03.text +
          ':' +
          mac04.text +
          ':' +
          mac05.text +
          ':' +
          mac06.text;
      await getAddress();
      print(address);
      _insert(1, widget.email, address, widget.userID, '1', '1', '0', '0');
      _controller.success();
      Navigator.pushReplacement(
          this.context,
          MaterialPageRoute(
            builder: (context) => Name(widget.email, widget.userID),
          ));
    } else {
      _controller.error();
      authenticationerror(
          'Veuillez entrer votre adresse MAC Bluetooth', this.context);
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            const link = 'https://aaronhaddad.github.io/scovid/data.html';
            if (await canLaunch(link)) {
              await launch(link);
            } else {
              authenticationerror('Veuillez visiter $link', context);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width - 10.0,
            height: 50.0,
            color: Color(0xff),
            padding: EdgeInsets.only(
                bottom: MediaQuery.textScaleFactorOf(context) * 20.0),
            child: Center(
              child: Text('Pourquoi toutes ses informations?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: MediaQuery.textScaleFactorOf(context) * 14.0,
                    letterSpacing: 0.5,
                  )),
            ),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    'Adresse Bluetooth',
                    maxLines: 1,
                    style: TextStyle(
                      color: Color(0xffffd051),
                      fontSize: MediaQuery.of(context).textScaleFactor * 20.0,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).textScaleFactor * 20.0)),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac01,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '1A',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac02,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '2B',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac03,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '3C',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac04,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '4D',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac05,
                      textCapitalization: TextCapitalization.characters,
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '5E',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    width: MediaQuery.of(context).textScaleFactor * 30.0,
                    child: TextFormField(
                      controller: mac06,
                      textCapitalization: TextCapitalization.characters,
                      onFieldSubmitted: (term) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        _controller.start();
                        macCollect();
                      },
                      maxLines: 1,
                      maxLength: 2,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Color(0xffffd051),
                            ),
                          ),
                          hintText: '6F',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide:
                                  new BorderSide(color: Colors.white54))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).textScaleFactor * 20.0),
            ),
            RoundedLoadingButton(
              controller: _controller,
              color: Color(0xff246bfd),
              borderRadius: 10.0,
              onPressed: () async {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                _controller.start();
                macCollect();
              },
              child: Text(
                'Suivant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).textScaleFactor * 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 20.0,
                    child: FlatButton(
                      height: 50.0,
                      color: Colors.purple,
                      onPressed: () {
                        SystemSettings.deviceInfo();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          Text(
                            'Aller aux\nparamètres',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 20.0,
                    child: FlatButton(
                      height: 50.0,
                      color: Colors.purple,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FindMac()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_support_sharp,
                            color: Colors.white,
                          ),
                          Text(
                            'Comment trouver\nmon adresse\nBluetooth?',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.textScaleFactorOf(context) * 12.0,
                            ),
                          )
                        ],
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
