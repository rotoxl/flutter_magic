import 'dart:collection';
import 'dart:io';

import 'package:app/ui/card_listing.dart';
import 'package:app/ui/config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:app/models/end_point.dart';

import 'package:app/app_data.dart';

class AppDataXLoader extends StatefulWidget{
  final void Function(AppData p) _themeUpdater;
  FirebaseAnalytics _analytics;

  AppDataXLoader(void Function(AppData p) this._themeUpdater, FirebaseAnalytics this._analytics);

  @override
  State<StatefulWidget> createState() => new _AppDataXLoaderState(this._analytics, _themeUpdater);
}

class _AppDataXLoaderState extends State<AppDataXLoader> {
  bool _loaded=false;
  FirebaseAnalytics _analytics;
  final void Function(AppData p) _themeUpdater;

  DateTime whatever;

  _AppDataXLoaderState(this._analytics, this._themeUpdater);

  @override
  Widget build(BuildContext context) {
    if (appData!=null)
        appData.analytics=this._analytics;

    return new Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }
  void _navigateNext(BuildContext context, AsyncSnapshot<HashMap<String, EndPoint>> snapshot) {
    var current=appData.getFixedEndPoint();
    if (current==null){
      Navigator.pushReplacement(context, new MaterialPageRoute(
        builder: (BuildContext context) {
          return new ConfigPage(_themeUpdater);
          },
      ));
    }
    else
      Navigator.pushReplacement(context, new MaterialPageRoute(
        builder: (BuildContext context){
            return new CardListing(_themeUpdater);
          }
        )
      );
  }

  _buildAppBar(BuildContext context){
    return AppBar(
      toolbarOpacity: .1,
    );
  }
  _buildBody(BuildContext context) {
    return FutureBuilder<HashMap<String, EndPoint>>(
        future: appData.loadEndPoints(),
        builder: (context, snapshot) {
          print ('snapshot, one more time');
          if (snapshot.connectionState==ConnectionState.none)
            return Center(child:Text('No internet connection. Tap to try again'));
          else if (snapshot.hasData && this._loaded==false) {
            this._loaded=true;
            print('loaded!');

            new Future.delayed(const Duration(milliseconds: 10), ()=>_navigateNext(context, snapshot));
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return
              GestureDetector(
                onTap: (){
                  setState(() {
                    whatever=DateTime.now();
                  });
                },
                child: Center(child:Text('Error starting app. Tap to try again'))
              );//TODO sacar un Admonition
          }
          // By default, show a loading spinner
          return Center(child: CircularProgressIndicator());
        });
  }

  Future<Widget> internetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Center(child:Text('Error starting app'));
      }
    } on SocketException catch (_) {
      return Center(child:Text('No internet connection'));
    }
  }
}