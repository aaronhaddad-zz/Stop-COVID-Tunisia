import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:stop_covid/app_in.dart';

class ActivateBluetooth extends StatefulWidget {
  final String email;
  final String userID;
  ActivateBluetooth(this.email, this.userID);

  @override
  _ActivateBluetoothState createState() => _ActivateBluetoothState();
}

class _ActivateBluetoothState extends State<ActivateBluetooth> {
  bool bluetoothEnabeled = false;

  @override
  void initState() {
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.on) {
        setState(() {
          bluetoothEnabeled = true;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AppIn(widget.email, widget.userID)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff262a34),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xff),
          title: Text(
            'Oops! Il semble que Bluetooth est désactivée',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.0,
              fontFamily: 'Raleway',
              letterSpacing: 1.0,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Icon(
            Icons.bluetooth,
            color: (bluetoothEnabeled) ? Colors.green : Colors.red,
            size: 80.0,
          ),
        ),
      ),
    );
  }
}
