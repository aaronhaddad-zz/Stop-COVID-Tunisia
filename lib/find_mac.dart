import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:system_settings/system_settings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FindMac extends StatefulWidget {
  FindMac({Key key}) : super(key: key);

  @override
  _FindMacState createState() => _FindMacState();
}

class _FindMacState extends State<FindMac> {
  YoutubePlayerController ytController = YoutubePlayerController(
      initialVideoId: 'Z_fR9wyhFy8',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ));
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff181a20),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Trouver mon adresse Bluetooth',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).textScaleFactor * 14.0,
              fontFamily: 'Poppins',
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          elevation: 0,
          backgroundColor: Color(0xff262a34),
        ),
        body: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Color(0xff),
            appBar: AppBar(
              backgroundColor: Color(0xff262a34),
              toolbarHeight: MediaQuery.of(context).textScaleFactor * 60.0,
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Icon(
                    Icons.android,
                  ),
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).textScaleFactor * 8.0),
                    child: Icon(Icons.phone_iphone_outlined),
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Container(
                  child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Color(0xff),
                        elevation: 0,
                        centerTitle: true,
                        title: Text(
                          'Paramètres -> A propos -> Statut',
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).textScaleFactor * 18.0,
                            fontFamily: 'Raleway',
                            wordSpacing: 2.0,
                          ),
                        ),
                      ),
                      backgroundColor: Color(0xff181a20),
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).textScaleFactor * 8.0),
                            child: Center(
                              child: Text(
                                'L\'adresse Bluetooth est sous la forme',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          14.0,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).textScaleFactor * 8.0,
                                0.0,
                                MediaQuery.of(context).textScaleFactor * 8.0,
                                0.0),
                            child: Center(
                              child: Text(
                                'A1:B2:C3:D4:E5:F6',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          14.0,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).textScaleFactor *
                                    25.0),
                          ),
                          YoutubePlayer(
                            controller: ytController,
                            showVideoProgressIndicator: true,
                            width: MediaQuery.of(context).size.width - 30.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15.0),
                          ),
                          RaisedButton(
                              color: Color(0xff262a34),
                              child: Text('Vers les paramètres',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).textScaleFactor *
                                            13.0,
                                    fontFamily: 'Raleway',
                                    color: Colors.white,
                                  )),
                              onPressed: () {
                                SystemSettings.deviceInfo();
                              }),
                        ],
                      )),
                ),
                Container(
                  width: 30.0,
                  height: MediaQuery.of(context).size.height - 100.0,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: Color(0xff181a20),
                      elevation: 0,
                      title: Text(
                        'Paramètres -> Générale -> A propos',
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 14.0,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      centerTitle: true,
                    ),
                    backgroundColor: Color(0xff181a20),
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).textScaleFactor * 8.0),
                          child: Center(
                            child: Text(
                              'L\'adresse Bluetooth ressemble un peu à ça!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor *
                                        16.0,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).textScaleFactor *
                                    25.0)),
                        Image.asset(
                          'assets/images/findmac2.jpg',
                          width: MediaQuery.of(context).size.width - 90.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height -
                                    600.0)),
                        RaisedButton(
                            color: Color(0xff262a34),
                            child: Text('Vers les paramètres',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          13.0,
                                  fontFamily: 'Raleway',
                                  color: Colors.white,
                                )),
                            onPressed: () {
                              SystemSettings.deviceInfo();
                            }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
