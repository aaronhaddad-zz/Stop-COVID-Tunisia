import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stop_covid/activate_bluetooth.dart';
import 'package:stop_covid/app_in.dart';
import 'package:stop_covid/how_to_use.dart';
import 'package:stop_covid/name.dart';
import 'package:stop_covid/positive.dart';
import 'package:workmanager/workmanager.dart';
import 'database/initdb.dart';
import 'mac_address.dart';

const notifyUser = "notifyUser";
final dbHelper = Initdb.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(
    callbackDispatcher,
    //isInDebugMode: true,
  );
  await Workmanager.registerPeriodicTask(
    "5",
    notifyUser,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    frequency: Duration(hours: 1),
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color(0xff181a20),
      accentColor: Color(0xff2f7aff),
    ),
    title: 'Stop COVID',
    home: SplashScreen(),
  ));
}

FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();
void showNotification() async {
  var androidDetails = new AndroidNotificationDetails(
      "channelId", "channelName", "channelDescription",
      importance: Importance.max, priority: Priority.max, icon: 'app_icon');
  var iosDetails = new IOSNotificationDetails();
  var notification =
      new NotificationDetails(android: androidDetails, iOS: iosDetails);

  await notificationPlugin.show(
    3,
    'Stop COVID',
    'Rappel: Stop COVID n\'est pas en cours d\'éxecution',
    notification,
  );
}

void callbackDispatcher() {
  Workmanager.executeTask(
    (task, inputData) async {
      var androidInitialize = new AndroidInitializationSettings('app_icon');
      var iosInitialize = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          android: androidInitialize, iOS: iosInitialize);
      notificationPlugin = new FlutterLocalNotificationsPlugin();
      notificationPlugin.initialize(initializationSettings,
          onSelectNotification: comeFromNotification);

      if (DateTime.now().hour >= 7 && DateTime.now().hour <= 19) {
        showNotification();
      }
      return Future.value(true);
    },
  );
}

Future comeFromNotification(String payload) async {}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BluetoothState state;
  int infection;
  final dbHelper = Initdb.instance;

  Future getInfection() async {
    try {
      infection = await dbHelper.infection();
    } catch (e) {
      infection = 10;
    }
  }

  String name;
  Future getName() async {
    try {
      name = await dbHelper.firstNameDb();
    } catch (e) {
      name = 'no';
    }
  }

  String firstTimeIn;
  Future firstTime() async {
    firstTimeIn = await dbHelper.firstTimeIn();
  }

  @override
  void initState() {
    super.initState();
    //Loggin the user in automatically
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        logInAutomatically().then((value) {
          if (value != null) {
            return new Timer(
                new Duration(seconds: 2),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ActivateBluetooth(value.email, value.uid))));
          } else {
            return new Timer(
                new Duration(seconds: 2),
                () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HowToUse())));
          }
        });
        return new Timer(
            new Duration(seconds: 2),
            () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HowToUse(),
                )));
      } else if (state == BluetoothState.on) {
        logInAutomatically().then((user) {
          if (user != null) {
            getInfection().then((inf) {
              if (infection == 1) {
                return new Timer(
                    new Duration(seconds: 2),
                    () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PositiveUser(user.email, user.uid),
                        )));
              } else if (infection == 0) {
                getName().then((val) {
                  if (name == null) {
                    return new Timer(
                        new Duration(seconds: 2),
                        () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Name(user.email, user.uid),
                            )));
                  } else {
                    return new Timer(
                        new Duration(seconds: 2),
                        () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppIn(user.email, user.uid),
                            )));
                  }
                });
              } else {
                return new Timer(
                    new Duration(seconds: 2),
                    () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MacAddress(user.email, user.uid),
                        )));
              }
            });
          } else {
            return pass();
          }
        });
      }
    });
  }

  //Detecting if the user is already signed in
  Future<FirebaseUser> logInAutomatically() async {
    return await FirebaseAuth.instance.currentUser();
  }

  pass() {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  void route() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HowToUse(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: MediaQuery.textScaleFactorOf(context) * 200.0,
        ),
      ),
    );
  }
}
