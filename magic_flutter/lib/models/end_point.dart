import 'dart:ui';
import 'package:flutter/material.dart';


class EndPoint{
  String title, url;
  String idField, imgField, nameField;

  Color color;
  String type="User";

  var mainFields=List<String>();
  var secondaryFields=List<String>();
  var statsFields=List<String>();


  EndPoint({this.title, this.url, this.color});

  List<String> fields(){
    //TODO dynamically load fields from 1st query

    List<String> members= ["name", "manaCost", "type", "rarity", "set", "setName", "text", "artist", "number", "power", "toughness", "layout", "imageUrl", "originalText", "originalType", "id",
    "cmc","multiverseid",
    "colors", "colorIdentity", "types", "subtypes", "printings"];

    return members;
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
    c.statsFields=List<String>.from(json['statsFields']);

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
    'statsFields': statsFields,
  };
//  List<HashMap<String, dynamic>> _values;
//  dynamic values(int rowNum, String field_id){
//    if (rowNum<0 || rowNum>=_values.length)
//      return null;
//
//    return _values[rowNum][field_id];
//  }
}