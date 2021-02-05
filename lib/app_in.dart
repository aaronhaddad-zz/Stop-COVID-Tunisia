import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stop_covid/activate_bluetooth.dart';
import 'package:stop_covid/authentication_errors.dart';
import 'package:stop_covid/database/initdb.dart';
import 'package:stop_covid/database/macdb.dart';
import 'package:stop_covid/health_window.dart';
import 'package:stop_covid/login.dart';
import 'package:stop_covid/positive.dart';
import 'package:stop_covid/user.dart';

import 'confirmation_box.dart';
import 'loading.dart';

//got a blumming amazing idea, insteaod uploading all the DATA online i will store everything in a local DB and store the infected MACs online, that way it will be easier to fectch for infected people... Smart hunhh!

class AppIn extends StatefulWidget {
  final String email;
  final String uid;
  AppIn(this.email, this.uid);

  @override
  _AppInState createState() => _AppInState();
}

class _AppInState extends State<AppIn> with WidgetsBindingObserver {
  //BG process
  StreamSubscription bleSubscription;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  _addDeviceToList(BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  BluetoothState state;
  bool isScanning = false;

  int macRows = -1;

  String userMac;
  String userID;
  String userEmail;
  String userInfection;
  String key;
  String firstName = 'name';
  String lastName = 'name';
  bool stopInfectionCheck = false;
  bool isSuspected = false;

  int scan = 0;

  PageController _pageController = PageController(
    initialPage: 0,
  );

  final dbHelper = Initdb.instance;
  final macdbHelper = Macdb.instance;

  final RoundedLoadingButtonController _controller =
      new RoundedLoadingButtonController();

//Getting data from local db
  Future getMac() async {
    userMac = await dbHelper.mac();
  }

  Future getMacRows() async {
    try {
      macRows = await macdbHelper.queryRowCount();
      setState(() {
        if (macRows != 0) {
          macRows = macRows;
        } else {
          macRows = -1;
        }
      });
    } catch (e) {
      macRows = -1;
    }
  }

  List<Map> macsDb;
  Future dbMacs() async {
    macsDb = await macdbHelper.dbContent();
  }

  Future getFirstName() async {
    firstName = await dbHelper.firstNameDb();
    setState(() {
      firstName = firstName;
    });
    await getDate();
    DateTime dateGot = DateTime(
      int.parse(date.toString().split('-')[0]),
      int.parse(date.toString().split('-')[1]),
      int.parse(date.toString().split('-')[2]),
    );
    if (DateTime.now().difference(dateGot).inDays == 16) {
      for (int i = 0; i <= macRows + 1; i++) {
        macdbHelper.delete(i);
      }
      _newDate();
    }
  }

  Future getLastName() async {
    lastName = await dbHelper.lastNameDb();
    setState(() {
      lastName = lastName;
    });
  }

  String scanReminder = '1';
  Future getReminded() async {
    scanReminder = await dbHelper.reminderBool();
  }

  String date;
  Future getDate() async {
    date = await dbHelper.date();
  }

  String sus;
  Future getSuspection() async {
    sus = await dbHelper.suspected();
    setState(() {
      if (sus == '1') {
        isSuspected = true;
      } else {
        isSuspected = false;
      }
    });
    return sus;
  }

  void _insert(int uid, String mac) async {
    // row to insert
    Map<String, dynamic> row = {
      Macdb.columnId: uid,
      Macdb.columnmac: mac,
    };
    final id = await macdbHelper.insert(row);
    macdbHelper.dbContent();
  }

  //Updating data for when infected
  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.columninfected: 1,
      Initdb.pushkey: key,
    };
    final rowsAffected = await dbHelper.update(row);
    dbHelper.dbContent();
  }

  void _newDate() async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.dateColumn: DateTime.now().year.toString() +
          '-' +
          DateTime.now().month.toString() +
          '-' +
          DateTime.now().day.toString(),
    };
    final rowsAffected = await dbHelper.update(row);
    dbHelper.dbContent();
  }

  //Updaating db if user is suspected of infection
  void _suspected() async {
    // row to update
    Map<String, dynamic> row = {
      Initdb.columnId: 1,
      Initdb.suspectedColumn: '1',
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

  bool _connectionAvaialable = false;
  //Check for connection
  Future checkConnection() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      _connectionAvaialable = true;
    } else {
      _connectionAvaialable = false;
    }
  }

  //Houni I will make a function that will run once every 15 minutes to check if konet in contact maa wehed positive
  //If that is the case we update l local db l positive o we navigate to PositiveUser
  //Also put his mac f firebase. Just the 'i am positive'

  Map<dynamic, dynamic> macsOnline;

  _scanReminder() {
    return new Timer.periodic(new Duration(minutes: 15), (timer) async {
      await getReminded();
      DateTime now = DateTime.now();
      if (now.hour >= 8 && now.hour < 19 && scanReminder == '1') {
        if (!isScanning) {
          _launchScanReminderNotification();
        }
      }
    });
  }

  bool suspicionOfInfection = false;

  Future<void> _checkForInfection() async {
    await getMacRows();
    if (_connectionAvaialable) {
      await getInfectedMacs();
    }
    return new Timer.periodic(new Duration(minutes: 1), (timer) async {
      await checkConnection();
      await getMac();
      if (_connectionAvaialable) {
        await getMacRows();
        await getInfectedMacs();
        if (stopInfectionCheck = true) {
          return timer.cancel();
        }
      }
    });
  }

  Future<void> getInfectedMacs() async {
    await dbMacs();
    final dbRef = FirebaseDatabase.instance.reference();
    dbRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> macs = snapshot.value;
      macs.forEach((key, value) {
        for (int i = 0; i < macs.length; i++) {
          for (int j = 0; j < macsDb.length; j++) {
            if (macs.values.toList()[i] == macsDb[j]['_mac'].toString()) {
              _suspected();
              setState(() {
                stopInfectionCheck = true;
                isSuspected = true;
              });
              suspicionOfInfection = true;
              _contractedAnInfectedPersonNotification();
              break;
            } else {
              setState(() {
                stopInfectionCheck = false;
                isSuspected = false;
              });
              suspicionOfInfection = false;
              _notSuspected();
              break;
            }
          }
        }
      });
    });
  }

  //Notification plugin
  FlutterLocalNotificationsPlugin notificationPlugin;

  //The notification itself
  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.max, priority: Priority.max, icon: 'app_icon');
    var iosDetails = new IOSNotificationDetails();
    var notification =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationPlugin.show(
        0, 'Stop COVID', 'Stop COVID scanne votre entourage!', notification);
  }

  Future _contractedAnInfectedPersonNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.max, priority: Priority.max, icon: 'app_icon');
    var iosDetails = new IOSNotificationDetails();
    var notification =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationPlugin.show(
      2,
      'Stop COVID',
      'Suspicion de contamination! Vous avez récemment été en contact avec une personne infectée!',
      notification,
    );
  }

  Future _launchScanReminderNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.max, priority: Priority.max, icon: 'app_icon');
    var iosDetails = new IOSNotificationDetails();
    var notification =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationPlugin.show(
        0, 'Stop COVID', 'N\'oubliez pas de lancer le scan', notification);
  }

  Future _appClosedNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.max, priority: Priority.max, icon: 'app_icon');
    var iosDetails = new IOSNotificationDetails();
    var notification =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await notificationPlugin.show(1, 'Stop COVID',
        'Veuillez ne pas enlever l\'application du multitâches', notification);
  }

  //Scan on demand
  void userRequestScan() {
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    bleSubscription =
        flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    //Workaround to scan forever
    flutterBlue.startScan(
      timeout: Duration(days: 999999),
      allowDuplicates: true,
      scanMode: ScanMode.lowLatency,
    );
    //print(FlutterBluetoothSerial.instance.startDiscovery().toList());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //Notification vars
    var androidInitialize = new AndroidInitializationSettings('app_icon');
    var iosInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iosInitialize);
    notificationPlugin = new FlutterLocalNotificationsPlugin();
    notificationPlugin.initialize(initializationSettings,
        onSelectNotification: comeFromNotification);

    FlutterBlue.instance.state.listen((state) async {
      if (state == BluetoothState.off) {
        //If Bluetooth is off then the user will be redirected lel how to use, keka el how tu use thezzou lel login ken bluetooth thal sinn yokod ghadi, that way we are sure elli this acticity is nly launched whrn bluetooth is on
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ActivateBluetooth(widget.email, widget.uid)));
      }
    });
    _scanReminder();
    _checkForInfection();
    getFirstName();
    getLastName();
    getMacRows();
    getSuspection().then((value) {
      if (sus == '1') {
        setState(() {
          isSuspected = true;
        });
      } else {
        isSuspected = false;
      }
    });
    notificationPlugin.cancel(3);
    Timer.periodic(Duration(minutes: 10), ((timer) {
      notificationPlugin.cancel(3);
    }));
  }

  @mustCallSuper
  @protected
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bleSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Timer _timer;

  void timer() {
    const dur = Duration(seconds: 1);
    _timer = Timer.periodic(dur, (t) {
      if (isScanning && bleSubscription.isPaused) {
        userRequestScan();
        bleSubscription.resume();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        notificationPlugin.cancel(1);
        _timer.cancel();
        break;
      case AppLifecycleState.inactive:
        if (isScanning) {
          _appClosedNotification();
        }
        timer();
        break;
      case AppLifecycleState.paused:
        if (isScanning) {
          _appClosedNotification();
        }
        timer();
        break;
      case AppLifecycleState.detached:
        if (isScanning) {
          _appClosedNotification();
        }
        bleSubscription.resume();
        break;
    }
  }

  Widget loadingCircle = SpinKitFoldingCube(
    color: Colors.white,
    size: 50.0,
  );

  //Handle what happens when notification is clicked
  Future comeFromNotification(String payload) async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: Scaffold(
          backgroundColor: Color(0xff181a20),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xff181a20),
            title: Text(
              'Stop COVID',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: MediaQuery.of(context).textScaleFactor * 18.0,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).textScaleFactor * 24.0,
                  top: MediaQuery.of(context).textScaleFactor * 16.0,
                  bottom: MediaQuery.of(context).textScaleFactor * 16.0,
                ),
                child: FlatButton(
                  color: (isSuspected) ? Colors.red : Colors.green,
                  height: 100,
                  child: Text(
                    'Ma santé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScaleFactorOf(context) * 12.0,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onPressed: () async {
                    await checkConnection();
                    if (_connectionAvaialable & !isScanning) {
                      loading(context, loadingCircle);
                      await getInfectedMacs();
                      await Future.delayed(
                        Duration(seconds: 2),
                      );
                      if (isSuspected) {
                        Navigator.pop(context);
                        healthWindow(context, true, firstName,
                            'vous avez été en contact avec un cas positif!');
                      } else {
                        Navigator.pop(context);
                        healthWindow(context, false, firstName,
                            'vous n\'avez pas été en contact avec un cas positif!');
                      }
                    } else if (!_connectionAvaialable) {
                      authenticationerror(
                          'Veuillez vous connecter à internet', context);
                    } else if (isScanning) {
                      authenticationerror(
                          'Veuiller arrêter l\'analyse.', context);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    side: BorderSide(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).textScaleFactor * 24.0),
                child: GestureDetector(
                  onTap: () async {
                    if (isScanning) {
                      authenticationerror('Veuillez arrêter le scan', context);
                    } else {
                      await getMac();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => User(
                                    this.firstName,
                                    this.lastName,
                                    widget.email,
                                    userMac,
                                    0,
                                    isSuspected,
                                  )));
                    }
                  },
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: MediaQuery.of(context).textScaleFactor * 22.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).textScaleFactor * 24.0),
                child: GestureDetector(
                  onTap: () {
                    if (isScanning) {
                      authenticationerror(
                          'Arrêter le scan avant de déconnecter', context);
                    } else {
                      confirmationBox(
                          'Déconnexion? Ceci va supprimer toutes les données',
                          context, () {
                        dbHelper.delete(1);
                        dbHelper.dbContent();
                        notificationPlugin.cancel(0);
                        dbHelper.delete(1);
                        devicesList.removeRange(0, devicesList.length);
                        for (int i = 0; i <= macRows + 1; i++) {
                          macdbHelper.delete(i);
                        }
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ));
                      }, 'Me déconnecter', 'Non, je rêste');
                    }
                  },
                  child: Icon(
                    Icons.logout,
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
                    width: 60.0,
                    height: 60.0,
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).textScaleFactor * 20.0,
                        right: MediaQuery.of(context).textScaleFactor * 20.0),
                    child: FloatingActionButton(
                      heroTag: 'btn1',
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
                            top:
                                MediaQuery.of(context).textScaleFactor * 20.0)),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).textScaleFactor * 25.0),
                      child: Text(
                        'Salut,\n' + firstName + ' ' + lastName + ' 👋',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 22.0,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                      top: MediaQuery.of(context).textScaleFactor * 10.0,
                    )),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).textScaleFactor * 25.0),
                        width: MediaQuery.of(context).size.width - 30,
                        height: MediaQuery.of(context).size.width - 170.0,
                        decoration: BoxDecoration(
                          color: Color(0xff262a34),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        child: Scaffold(
                          appBar: AppBar(
                            elevation: 0,
                            actions: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (isScanning) {
                                      scan++;
                                      for (int i = 0;
                                          i < devicesList.length;
                                          i++) {
                                        await getMacRows();
                                        _insert(macRows + 1,
                                            devicesList[i].name.toString());
                                        macdbHelper.dbContent();
                                      }
                                      notificationPlugin.cancel(0);
                                      flutterBlue.stopScan();
                                      devicesList.removeRange(
                                          0, devicesList.length);
                                      setState(() {
                                        isScanning = false;
                                      });
                                    } else {
                                      if (!await GeolocatorPlatform.instance
                                          .isLocationServiceEnabled()) {
                                        return authenticationerror(
                                            'Veuillez activer le GPS', context);
                                      }
                                      _showNotification();
                                      userRequestScan();
                                      setState(() {
                                        isScanning = true;
                                      });
                                      new Timer.periodic(
                                          new Duration(minutes: 1),
                                          (timer) async {
                                        for (int i = 0;
                                            i < devicesList.length;
                                            i++) {
                                          await getMacRows();
                                          _insert(macRows + 1,
                                              devicesList[i].name.toString());
                                          macdbHelper.dbContent();
                                        }
                                        if (!isScanning) {
                                          timer.cancel();
                                        }
                                      });
                                    }
                                  },
                                  child: Icon(Icons.scanner_outlined,
                                      size: MediaQuery.of(context)
                                              .textScaleFactor *
                                          28.0,
                                      color: (isScanning)
                                          ? Colors.green
                                          : Color(0xffdc3545)),
                                ),
                              ),
                            ],
                            title: Text(
                              'Vous avez été en contact avec',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        13.0,
                              ),
                            ),
                            backgroundColor: Color(0xff262a34),
                          ),
                          body: Container(
                            color: Color(0xff262a34),
                            child: ListView.separated(
                              separatorBuilder: (context, index) => Divider(),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    //'Personne(s)',
                                    devicesList[index].name.toString() +
                                        ' ' +
                                        devicesList[index].id.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          13.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius:
                                        MediaQuery.of(context).textScaleFactor *
                                            16.0,
                                    backgroundColor: Color(0xff246bfd),
                                    child: Text(
                                      (devicesList.length - index).toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: devicesList.length,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top:
                                MediaQuery.of(context).textScaleFactor * 20.0)),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 90.0,
                        height: MediaQuery.of(context).textScaleFactor * 50.0,
                        child: RoundedLoadingButton(
                          controller: _controller,
                          width: MediaQuery.of(context).size.width - 150.0,
                          elevation: 2,
                          onPressed: () async {
                            _controller.start();
                            if (!isScanning) {
                              confirmationBox('Vous confirmez?', context,
                                  () async {
                                await checkConnection();
                                if (_connectionAvaialable) {
                                  loading(context, loadingCircle);
                                  userMac = await dbHelper.mac();
                                  key = FirebaseDatabase.instance
                                      .reference()
                                      .push()
                                      .key;
                                  await FirebaseDatabase.instance
                                      .reference()
                                      .child(key)
                                      .set(userMac);
                                  _update();
                                  _controller.success();
                                  await new Future.delayed(
                                      new Duration(seconds: 1));
                                  return Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PositiveUser(
                                            widget.email, widget.uid),
                                      ),
                                      (route) => false);
                                } else {
                                  _controller.error();
                                  authenticationerror(
                                      'Veuillez vous connecter à internet',
                                      context);
                                  await Future.delayed(
                                      new Duration(seconds: 1));
                                  _controller.reset();
                                }
                              }, 'Oui', 'Non');
                              _controller.reset();
                            } else {
                              authenticationerror(
                                  'Veuillez arrêter l\'analyse', context);
                              _controller.error();
                              await Future.delayed(Duration(seconds: 1));
                              _controller.reset();
                            }
                          },
                          child: Text(
                            'Je suis positif au COVID-19',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 12.0,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          color: Color(0xff171582),
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
                      fontSize: MediaQuery.of(context).textScaleFactor * 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                backgroundColor: Color(0xff),
                bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BottomAppBar(
                      elevation: 0,
                      color: Color(0xff),
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).textScaleFactor * 20.0,
                            left:
                                MediaQuery.of(context).textScaleFactor * 20.0),
                        child: FloatingActionButton(
                          heroTag: 'btn2',
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
                        ),
                        child: FloatingActionButton(
                          heroTag: 'btn3',
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
                    BottomAppBar(
                      elevation: 0,
                      color: Color(0xff),
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).textScaleFactor * 20.0,
                            right:
                                MediaQuery.of(context).textScaleFactor * 20.0),
                        child: FloatingActionButton(
                          heroTag: 'btn4',
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
                  ],
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            top:
                                MediaQuery.of(context).textScaleFactor * 20.0)),
                    GestureDetector(
                      onTap: () {},
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 60.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: Color(0xff262a34),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).textScaleFactor *
                                        8.0),
                              ),
                              Icon(
                                Icons.masks,
                                size: MediaQuery.of(context).textScaleFactor *
                                    60.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Portez toujours\nvotre masque!',
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
                                      right: MediaQuery.of(context)
                                              .textScaleFactor *
                                          10.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top:
                                MediaQuery.of(context).textScaleFactor * 20.0)),
                    GestureDetector(
                      onTap: () {},
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 60.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: Color(0xff262a34),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).textScaleFactor *
                                        8.0),
                              ),
                              Icon(
                                Icons.clean_hands_outlined,
                                size: MediaQuery.of(context).textScaleFactor *
                                    60.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Désinfectez vos mains le\nplus souvent!',
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
                                      right: MediaQuery.of(context)
                                              .textScaleFactor *
                                          10.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top:
                                MediaQuery.of(context).textScaleFactor * 20.0)),
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
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).textScaleFactor *
                                        8.0),
                              ),
                              Icon(
                                Icons.masks,
                                size: MediaQuery.of(context).textScaleFactor *
                                    60.0,
                                color: Colors.white,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Une distance de\nun metre!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context)
                                                .textScaleFactor *
                                            12.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context)
                                              .textScaleFactor *
                                          10.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Scaffold(
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
                              bottom:
                                  MediaQuery.of(context).textScaleFactor * 20.0,
                              left: MediaQuery.of(context).textScaleFactor *
                                  20.0),
                          child: FloatingActionButton(
                            heroTag: 'btn8',
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
                              bottom:
                                  MediaQuery.of(context).textScaleFactor * 20.0,
                              right: MediaQuery.of(context).textScaleFactor *
                                  20.0),
                          child: FloatingActionButton(
                            heroTag: 'btn9',
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).textScaleFactor * 50.0,
                            bottom:
                                MediaQuery.of(context).textScaleFactor * 40.0,
                            left: MediaQuery.of(context).textScaleFactor * 20.0,
                            right:
                                MediaQuery.of(context).textScaleFactor * 20.0),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 60.0,
                          child: RoundedLoadingButton(
                            controller: _controller,
                            width: MediaQuery.of(context).size.width - 150.0,
                            onPressed: () async {
                              _controller.start();
                              if (!isScanning) {
                                confirmationBox('Vous confirmez?', context,
                                    () async {
                                  await checkConnection();
                                  if (_connectionAvaialable) {
                                    loading(context, loadingCircle);
                                    userMac = await dbHelper.mac();
                                    key = FirebaseDatabase.instance
                                        .reference()
                                        .push()
                                        .key;
                                    await FirebaseDatabase.instance
                                        .reference()
                                        .child(key)
                                        .set(userMac);
                                    _update();
                                    _controller.success();
                                    await new Future.delayed(
                                        new Duration(seconds: 1));
                                    return Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PositiveUser(
                                              widget.email, widget.uid),
                                        ),
                                        (route) => false);
                                  } else {
                                    _controller.error();
                                    authenticationerror(
                                        'Veuillez vous connecter à internet',
                                        context);
                                    await Future.delayed(
                                        new Duration(seconds: 1));
                                    _controller.reset();
                                  }
                                }, 'Oui', 'Non');
                                _controller.reset();
                              } else {
                                authenticationerror(
                                    'Veuillez arrêter l\'analyse', context);
                                _controller.error();
                                await Future.delayed(Duration(seconds: 1));
                                _controller.reset();
                              }
                            },
                            child: Text(
                              'Je suis positif au COVID-19',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        12.0,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            color: Color(0xff171582),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).textScaleFactor * 50.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: 160.0,
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
                                    top:
                                        MediaQuery.of(context).textScaleFactor *
                                            20.0),
                                child: Text(
                                  (macRows + 1).toString(),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            20.0,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff84c36e),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).textScaleFactor *
                                            20.0,
                                    left:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0,
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0),
                                child: Text(
                                  'Pérsonnes seront ainsi informé de la suspicion de contamination!\n',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xfffbfbfb),
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          12.0,
                                      letterSpacing: 1.0,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                        MediaQuery.of(context).textScaleFactor *
                                            20.0,
                                    right:
                                        MediaQuery.of(context).textScaleFactor *
                                            20.0),
                                child: Text(
                                  'Vous protéger c\'est bien, protéger les autres c\'est mieux!',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Color(0xff515563),
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            10.0,
                                    fontFamily: 'Raleway',
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
