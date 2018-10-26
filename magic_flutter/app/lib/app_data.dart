import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/models/end_point.dart';
import 'package:app/ui/widgets.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

enum MColors{
  red,
  pink,
  purple,
  deepPurple,
  indigo,
  blue,
  lightBlue,
  cyan,
  teal,
  green,
  lightGreen,
  lime,
  yellow,
  amber,
  orange,
  deepOrange,
  brown,
  // The grey swatch is intentionally omitted because when picking a color
  // randomly from this list to colorize an application, picking grey suddenly
  // makes the app look disabled.
  blueGrey,
}

class AppData{
  static bool productionMode=true;
  HashMap<String, EndPoint> _endPoints=HashMap<String, EndPoint>();
  String _fixedEndPoint;

  EPTheme themeApplied;

  FirebaseAnalytics analytics;

  Future<Null> logEvent(name, Map<String, dynamic> parameters) async{
//    await appData.analytics.logEvent(name: name, /*parameters:parameters*/);
  }
  Future<Null> logScreen(name) async{
    await appData.analytics.setCurrentScreen(screenName: name);
  }


  EndPoint getEndPoint(String id) {
    if (_endPoints.length>0)
      return _endPoints[id];
    else {
      loadEndPoints();
      return _endPoints[id];
    }
  }
  String getFixedEndPoint(){
    return _fixedEndPoint;
  }
  EndPoint getCurrEndPoint(){
    if (_fixedEndPoint==null){
      loadEndPoints();
    }

    if (_fixedEndPoint!=null && !this._endPoints.containsKey(_fixedEndPoint))
      _fixedEndPoint=this._endPoints.keys.toList()[0];

    return getEndPoint(_fixedEndPoint);
  }
  void setCurrEndPoint(String id){
    _fixedEndPoint=id;
    saveLastUsed();
  }

  ThemeData darkTheme(){
    return ThemeData.dark().copyWith(
        accentColor: Colors.grey[800],
        buttonColor: Colors.grey[800],
        primaryColor:Colors.grey[800],
    );
  }


  _loadPlanetsAPI(){
    /*https://api.myjson.com/bins/133s70 --> https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json
    {
     "id": 1,
    "name": "Mercury",
    "mass": "0.33",
    "diameter": 4879,
    "density": 5427,
    "gravity": "3.7",
    "rotation_period": "1407.6",
    "length_of_day": "4222.6",
    "distance_from_sun": "57.9",
    "orbital_period": "88.0",
    "orbital_velocity": "47.4",
    "mean_temperature": 167,
    "number_of_moons": 0,
    "created_at": "2017-11-12T22:46:36.587Z",
    "updated_at": "2017-11-12T22:46:36.587Z",
    "img": "https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/mercury.jpg"
    }*/

  ///common stuff
    var epTheme=EPTheme();
    epTheme.theme=darkTheme().copyWith(accentColor: Colors.white); epTheme.color=Colors.black;

    var about=EPAbout();
    about.web='https://github.com/rotoxl/flutter_magic/blob/master/aboutPlanetsAPI.md';
    about.info='Planets in our Solar System';
    about.logo='https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg';

    var catList=['Science', 'Reference'];

    EPSeparatorWidget separator=EPSeparatorWidget();
    EPWidget wname=EPNameWidget();
      var en=EPLabelText();
      en.field="name";
      wname.fields=[en];

    var fields=['number_of_moons', 'mass', 'diameter', 'density', 'gravity', 'mean_temperature', 'rotation_period'];
    var labels=['Moons',           'Mass (x10e24 kg)', 'Diameter', 'Density', 'Gravity (m/s2)', 'Mean temperature', 'Rotation period (h)'];
    EPWidget wfields=EPFieldsWidget();
    for (var i=0; i<fields.length; i++){
      EPSubItem e=EPLabelText();
      e.field=fields[i];
      e.label=labels[i];
      wfields.fields.add(e);
    }

    EPImagesWidget wimages=EPImagesWidget();
    var ei=EPImage();
      ei.field='img';
      ei.type=ImageType.image;
      wimages.images=[ei];

    EPWidget wstats=EPStatsWidget();
      var e=EPLabelText(); e.field='number_of_moons'; e.label='Moons';
      var f=EPLabelText(); f.field='mass'; f.label='Mass (x10e24 kg)';
      wstats.fields=[e, f];

    EPWidget whero=EPHeroWidget();

    EPHeaderWidget wheaderDetail=EPHeaderWidget();
    wheaderDetail.left=[wimages];
      wheaderDetail.right=[wname, separator, wstats];

    EPHeaderWidget wheaderCompare=EPHeaderWidget();
    wheaderCompare.left=[wimages,  separator, wname];
    wheaderCompare.right=[wimages, separator, wname];

    ///
  var planets=new EndPoint(endpointTitle:'Solar system (Compare)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json');

    planets.epTheme=epTheme;
    planets.about=about;
    planets.type='Bundled';
    planets.typeOfListing=TypeOfListing.gridWithoutName;
    planets.typeOfDetail=TypeOfDetail.productCompare;
    planets.categories=catList;

    planets.id='id';
    planets.widgets=[wname, wfields, wimages];
    planets.widgetsOrder=[whero, wheaderCompare, separator, wfields];

    planets.images=wimages;
    planets.names=wname;
    _endPoints[planets.endpointTitle]=planets;

  /*----------------*/
  var planetsHero=new EndPoint(endpointTitle:'Solar system (Hero)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json');

    planetsHero.epTheme=epTheme;
    planetsHero.about=about;
    planetsHero.type='Bundled';
    planetsHero.typeOfListing=TypeOfListing.gridWithName;
    planetsHero.typeOfDetail=TypeOfDetail.hero;
    planetsHero.categories=catList;

    planetsHero.id=planets.id;
    planetsHero.widgets=planets.widgets;
    planetsHero.widgetsOrder=[whero, wname];

    planetsHero.images=wimages;
    planetsHero.names=wname;
  _endPoints[planetsHero.endpointTitle]=planetsHero;

  /*----------------*/
  var planetsDetail=new EndPoint(endpointTitle:'Solar system (Detail)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json');

    planetsDetail.epTheme=epTheme;
    planetsDetail.about=about;
    planetsDetail.type='Bundled';
    planetsDetail.typeOfListing=TypeOfListing.gridWithoutName;
    planetsDetail.typeOfDetail=TypeOfDetail.details;
    planetsDetail.categories=catList;

    planetsDetail.id='id';
    planetsDetail.widgets=[wname, wfields, wimages, whero];
    planetsDetail.widgetsOrder=[whero, wheaderDetail, separator, wfields/*, wimages*/];

    planetsDetail.images=wimages;
    planetsDetail.names=wname;
    _endPoints[planetsDetail.endpointTitle]=planetsDetail;

  /*----------------*/
    return planetsDetail.endpointTitle;
  }

  Future<HashMap<String, EndPoint>> loadEndPoints() async {
    print ('loadEndPoints... bundled');

    //bundled APIs (from https://github.com/toddmotto/public-apis)
    _loadPlanetsAPI();

    print ('loadEndPoints... firebase.remoteconfig');
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(minutes: 0));
    await remoteConfig.activateFetched();
    String r=remoteConfig.getString('init_endpoints');
    try{
      if (r!=null) parseFirebaseRemoteConfig(r);
    } catch (e){
      appData.logEvent("err_on_remote_config", {"version_code":remoteConfig.getString('version_code'), "err":e.toString()});
    }

    print ('loadEndPoints... localstorage'); //bundled APIs are overwritten by these
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var temp=prefs.getString("user_endpoints");

    if (temp!=null){
//      var jsondata=json.decode(temp);
//      List<dynamic>jsonep=jsondata['endPoints'];
//      for (var i=0; i<jsonep.length; i++){
//        var e=EndPoint.fromJson(jsonep[i]);
//        _endPoints[e.endpoint_title]=e;
//      }

    }

    var lastEndpoint=prefs.getString("last_endpoint");
    if (lastEndpoint!=null) this._fixedEndPoint=lastEndpoint;

    return _endPoints;
  }

  endPoints(){
    return _endPoints;
  }
  Map<String, dynamic> toJson() => {
    'endPoints': _endPoints.values.toList(),
  };

  Future<bool> save() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var json=jsonEncode(this.toJson());
    print ('about to save: $json');
    prefs.setString("user_endpoints", json );

    print ('save: done $json');
    return true;
  }
  Future<bool> saveLastUsed() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("last_endpoint", this.getCurrEndPoint().endpointTitle);
    return true;
  }

  void parseFirebaseRemoteConfig(String r) {
    var endpoints=json.decode(r)['default_endpoints'];
    if (endpoints==null) return;

    for (var i=0; i<endpoints.length; i++){
        var j=endpoints[i];

        try {
          print(j['endpointTitle']);
          var ep=new EndPoint.fromJson(j);

          ep.type='Bundled';

          _endPoints[ep.endpointTitle]=ep;
        } catch (err){
          print (err);
        }
    }
  }

  static void debugPrintSection(bool debug_showLog, String literal, dynamic json) {
    if (debug_showLog) {
      print (' ');
      print (' ');
      print (' ');
      print ('========================');
      debugPrint(debug_showLog, literal, json);
    }
  }
  static void debugPrint(bool debug_showLog, String literal, dynamic json) {
    if (debug_showLog){
      print ('>'+literal);
      print (json);
    }
  }

}
AppData appData=new AppData();