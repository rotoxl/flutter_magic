import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:magic_flutter/models/model_card.dart';


class EndPoint{
  String endpointTitle, endpointUrl;

  String id, name, text;

  String related;//points to a related item: eg parent
  var images=List<String>();

  var tags=List<String>();
  var stats=List<String>();
  var fields=List<String>();

  Color color;
  String type="User";

  Map<String, String> headers; //para identificación

  EndPoint({this.endpointTitle, this.endpointUrl, this.color});

  List<String> allFields(){
    //TODO dynamically load fields from 1st query

    List<String> members= ["name", "manaCost", "type", "rarity", "set", "setName", "text", "artist", "number", "power", "toughness", "layout", "imageUrl", "originalText", "originalType", "id",
    "cmc","multiverseid",
    "colors", "colorIdentity", "types", "subtypes", "printings"];

    return members;
  }

  firstImage(){
    if (this.images.length==0)
      return null;
    else
      return this.images[0];
  }
  secondImage(){
    if (this.images.length==0)
      return null;
    else if (this.images.length==1)
      return this.images[0];
    else
      return this.images[1];
  }

  List<ModelCard> _cards=new List<ModelCard>();
  get cards{
    return _cards;
  }
  set cards(List<ModelCard>newcards){
    this._cards=newcards;
  }
  clearCards(){
    _cards.clear();
  }

  factory EndPoint.fromJson(Map<String, dynamic> json) {
    var c=EndPoint();

    c.endpointTitle=json['title'];
    c.endpointUrl=json['url'];
    c.color=json['color'];

    c.id=json['id'];
    c.name=json['name'];
    c.text=json['text'];

    c.images=List<String>.from(json['images']);

    c.fields=List<String>.from(json['fields']);
    c.stats=List<String>.from(json['stats']);
    c.tags=List<String>.from(json['tags']);

    return c;
  }
  Map<String, dynamic> toJson() => {
    'title': endpointTitle,
    'url': endpointUrl,

    'id': id,
    'name': name,
    'text': text,

    'images': images,
    'stats': stats,
    'tags': tags,
    'fields': fields,

    //'color': color,
    'type': type,
  };
//  List<HashMap<String, dynamic>> _values;
//  dynamic values(int rowNum, String field_id){
//    if (rowNum<0 || rowNum>=_values.length)
//      return null;
//
//    return _values[rowNum][field_id];
//  }
}