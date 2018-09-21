import 'dart:collection';

import 'package:app/ui/card_listing.dart';
import 'package:app/ui/config.dart';
import 'package:flutter/material.dart';
import 'package:app/models/end_point.dart';

import 'package:app/app_data.dart';

class AppDataXLoader extends StatelessWidget{
  bool loaded=false;
  void Function(AppData p) _themeUpdater;

  AppDataXLoader(void Function(AppData p) this._themeUpdater);

  @override
  Widget build(BuildContext context) {
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
          return new ConfigPage(null);
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

          if (snapshot.hasData && this.loaded==false) {
            this.loaded=true;
            print('loaded!');

            new Future.delayed(const Duration(milliseconds: 10), ()=>_navigateNext(context, snapshot));
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(//TODO sacar un Admonition
                child:Text('Error starting app')
            );
          }
          // By default, show a loading spinner
          return Center(child: CircularProgressIndicator());
        });
  }

}