import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/models/end_point.dart';
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
  HashMap<String, EndPoint> _endPoints=HashMap<String, EndPoint>();
  String _fixedEndPoint;

  Object themeApplied;

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
        buttonColor: Colors.grey[800]
    );
  }
  _loadSportsAPI(){
    var match=new EndPoint(endpointTitle:'2018 Fifa WorldCup Russia', endpointUrl:'http://worldcup.sfg.io/matches', theme:darkTheme());

    match.id='fifa_id';  //books.text='{searchInfo/textSnippet}';
//    books.stats=['{restaurant/user_rating/aggregate_rating}', '{restaurant/user_rating/votes}'];
//    books.tags=['{volumeInfo/maturityRating}', '{volumeInfo/printType}', '{volumeInfo/categories/0}'];
//    match.fields=['{volumeInfo/infoLink}'/*, '{volumeInfo/authors}'*/];

    match.section='stage_name'; //just to group listing
    match.names=[
      '{home_team/country}',
      '{away_team/country}'
    ];
    match.images=[
      "https://raw.githubusercontent.com/rotoxl/country-flags/master/png100px_by_cioc/{home_team/code}.png",
      "https://raw.githubusercontent.com/rotoxl/country-flags/master/png100px_by_cioc/{away_team/code}.png"
    ];

    match.type='Bundled';

    match.aboutWeb='https://worldcup.sfg.io/';
    match.aboutDoc='https://github.com/estiens/world_cup_json';
    match.aboutInfo='World cup 2018... in JSON';

    match.typeOfListing=TypeOfListing.match;
    match.typeOfDetail=TypeOfDetail.match;

    _endPoints[match.endpointTitle]=match;
    return match.endpointTitle;
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


  var planets=new EndPoint(endpointTitle:'Solar system (Compare)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json', theme:darkTheme() );
    planets.color=Colors.black;

    planets.headers=null;
    planets.id='id'; planets.name='name'; planets.text=null;
    planets.fields=['number_of_moons', 'mass', 'diameter', 'density', 'gravity', 'mean_temperature', ];

    planets.images=['img', 'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg'];
    planets.type='Bundled';

    planets.aboutWeb='https://github.com/rotoxl/flutter_magic/blob/master/aboutPlanetsAPI.md';
//    planets.aboutDoc='https://developers.google.com/books/docs/v1/reference/';
    planets.aboutInfo='Planets in our Solar System';
    planets.aboutLogo='https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg';

    planets.typeOfListing=TypeOfListing.gridWithoutName;
    planets.typeOfDetail=TypeOfDetail.productCompare;

    _endPoints[planets.endpointTitle]=planets;


  /*----------------*/
    var planetsHero=new EndPoint(endpointTitle:'Solar system (Hero)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json', theme:darkTheme() );
    planetsHero.color=Colors.black;

    planetsHero.headers=null;
    planetsHero.id='id'; planetsHero.name='name'; planetsHero.text=null;
    planetsHero.fields=['number_of_moons', 'mass', 'diameter', 'density', 'gravity', 'mean_temperature', ];

    planetsHero.images=['img', 'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg'];
    planetsHero.type='Bundled';

    planetsHero.aboutWeb='https://github.com/rotoxl/flutter_magic/blob/master/aboutPlanetsAPI.md';
//    planets.aboutDoc='https://developers.google.com/books/docs/v1/reference/';
    planetsHero.aboutInfo='Planets in our Solar System';
    planetsHero.aboutLogo='https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg';

    planetsHero.typeOfListing=TypeOfListing.gridWithName;
    planetsHero.typeOfDetail=TypeOfDetail.hero;

    _endPoints[planetsHero.endpointTitle]=planetsHero;

  /*----------------*/
    var planetsDetail=new EndPoint(endpointTitle:'Solar system (Detail)', endpointUrl:'https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.json', theme:darkTheme() );
    planetsDetail.color=Colors.black;

    planetsDetail.headers=null;
    planetsDetail.id='id'; planetsDetail.name='name'; planetsDetail.text=null;
    planetsDetail.stats=['number_of_moons', 'mass'];
    planetsDetail.fields=['diameter', 'density', 'gravity', 'mean_temperature', 'orbital_velocity', 'orbital_period'];

    planetsDetail.images=['img'];
    planetsDetail.type='Bundled';

    planetsDetail.aboutWeb='https://github.com/rotoxl/flutter_magic/blob/master/aboutPlanetsAPI.md';
//    planets.aboutDoc='https://developers.google.com/books/docs/v1/reference/';
    planetsDetail.aboutInfo='Planets in our Solar System';
    planetsDetail.aboutLogo='https://s3-eu-west-1.amazonaws.com/api-explorer-app/planets/planets.jpg';

    planetsDetail.typeOfListing=TypeOfListing.gridWithoutName;
    planetsDetail.typeOfDetail=TypeOfDetail.details;

    _endPoints[planetsDetail.endpointTitle]=planetsDetail;




    return planets.endpointTitle;

  }

  Future<HashMap<String, EndPoint>> loadEndPoints() async {
    print ('loadEndPoints... bundled');

    //bundled APIs (from https://github.com/toddmotto/public-apis)

    _loadPlanetsAPI();
    _loadSportsAPI();

    print ('loadEndPoints... firebase.remoteconfig');
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(minutes: 60));
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

    List<Color> colorList=[Colors.black, Colors.red, Colors.yellow, Colors.orange, Colors.green, Colors.blue, Colors.indigo, Colors.pink];
    for (var i=0; i<endpoints.length; i++){
        var j=endpoints[i];

        var colorIndex=i;
        if (colorIndex>colorList.length-1)
          colorIndex=colorIndex % colorList.length;

        try {
          print(j['endpointTitle']);
          var ep=new EndPoint.fromJson(j);

          ep.type='Bundled';
          if (ep.color==null && ep.theme==null)
            ep.color=colorList[colorIndex];

          _endPoints[ep.endpointTitle]=ep;
        } catch (err){
          print (err);
        }
    }

  }


}
AppData appData=new AppData();