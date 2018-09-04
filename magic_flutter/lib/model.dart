import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';


class ModelCard{
//  String name, manaCost, type, rarity, set, setName, text, artist, number, power, toughness, layout, imageUrl, originalText, originalType, id;
//  int cmc, multiverseid;
//  List<dynamic> colors, colorIdentity, types, subtypes, printings;


  String id;
  Map<String, dynamic> json;
  //final Map rulings, legalities;

  get(String field){
    return json[field];
  }
  ModelCard({this.id});

  factory ModelCard.fromJson(Map<String, dynamic> json) {
    var c=ModelCard(id: json['id']);

    c.json=json;
    return c;
  }
}

Future<List<ModelCard>> fetchPost() async {
  final response = await http.get(appData.getCurrEndPoint().url);


  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var jsonCards=json.decode(response.body)['cards'];

    var cards=List<ModelCard>();
    for (var i=0; i<jsonCards.length; i++){
      cards.add( ModelCard.fromJson(jsonCards[i]) );
    }
    return cards;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}




class EndPoint{
  String title, url;
  String idField, imgField, nameField;

  Color color;
  String type="User";

  var mainFields=List<String>();
  var secondaryFields=List<String>();


  EndPoint({this.title, this.url, this.color});

  List<String> fields(){
    //TODO dynamically load fields from 1st query

    List<String> members= ["name", "manaCost", "type", "rarity", "set", "setName", "text", "artist", "number", "power", "toughness", "layout", "imageUrl", "originalText", "originalType", "id",
      "cmc","multiverseid",
      "colors", "colorIdentity", "types", "subtypes", "printings"];

    return members;
  }

  Future<bool> save() async{
    return appData.save();
  }

  factory EndPoint.fromJson(Map<String, dynamic> json) {
    var c=EndPoint();

    c.title=json['title'];
    c.url=json['url'];
    c.color=json['color'];

    c.idField=json['idField'];
    c.imgField=json['imgField'];

    c.mainFields=List<String>.from(json['mainFields']);
    c.secondaryFields=List<String>.from(json['secondaryFields']);

    return c;
  }
  Map<String, dynamic> toJson() => {
      'title': title,
      'url': url,

      'idField': idField,
      'imgField': imgField,
      'nameField': nameField,

      //'color': color,
      'type': type,

      'mainFields': mainFields,
      'secondaryFields': secondaryFields,
    };
//  List<HashMap<String, dynamic>> _values;
//  dynamic values(int rowNum, String field_id){
//    if (rowNum<0 || rowNum>=_values.length)
//      return null;
//
//    return _values[rowNum][field_id];
//  }
}

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