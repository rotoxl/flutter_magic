import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:magic_flutter/models/end_point.dart';


class AppData{
  HashMap<String, EndPoint> _endPoints=HashMap<String, EndPoint>();
  String _fixedEndPoint="Magic: The Gathering";

  EndPoint getEndPoint(String id) {
    if (_endPoints.length>0)
      return _endPoints[id];
    else {
      loadEndPoints();
      return _endPoints[id];
    }
  }
  EndPoint getCurrEndPoint(){
    return getEndPoint(_fixedEndPoint);
  }

  Future<HashMap<String, EndPoint>> loadEndPoints() async {
    //bundled APIs
    var magic=EndPoint(title:"Magic: The Gathering", url:"https://api.magicthegathering.io/v1/cards", color:Colors.orange);
    magic.idField="id"; magic.imgField="imageUrl"; magic.nameField="name";
    magic.mainFields=["name", "text"]; magic.secondaryFields=["type", "artist", "setName"];
    magic.type="Bundled";
    _endPoints[magic.title]=magic;

    var endpoint2=EndPoint(title:"Second endpoint", url:"https://api.magicthegathering.io/v1/cards", color:Colors.orange);
    endpoint2.idField="id"; endpoint2.imgField="imageUrl"; endpoint2.nameField="name";
    endpoint2.mainFields=["name", "text"]; endpoint2.secondaryFields=["type", "artist", "setName"];
    endpoint2.type="Bundled";
    _endPoints[endpoint2.title]=endpoint2;


    //load from storage: bundled APIs are overwritten by these
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var temp=prefs.getString("api_endpoint");
    print (temp);

    if (temp!=null){
      var jsondata=json.decode(temp);

      List<dynamic>json_endpoints=jsondata['endPoints'];
      for (var i=0; i<json_endpoints.length; i++){
        var e=EndPoint.fromJson(json_endpoints[i]);
        _endPoints[e.title]=e;
      }
    }

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
    print ('about to save: ${json}');
    prefs.setString("api_endpoint", json );

    print ('save: done ${json}');
    return true;
  }

}
AppData appData=AppData();