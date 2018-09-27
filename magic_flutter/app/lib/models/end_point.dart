import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:app/models/model_card.dart';

enum TypeOfListing{list, gridWithoutName, gridWithName}
enum TypeOfDetail{
  detailsPage,
  match,
  productCompare,
  heroPage //https://www.uplabs.com/posts/lonely-planet-hp-destination-selector
}

class EndPoint{
  TypeOfListing typeOfListing=TypeOfListing.gridWithName;
  TypeOfDetail typeOfDetail=TypeOfDetail.detailsPage;

  String endpointTitle, endpointUrl;

  String id, name, text;

  String related;//points to a related item: eg parent
  var images=List<String>();

  var tags=List<String>();
  var stats=List<String>();
  var fields=List<String>();

  String type="User";

  Map<String, String> headers;

  String aboutDoc, aboutWeb, aboutInfo, aboutLogo;

  Color color; ThemeData theme;

  EndPoint({this.endpointTitle, this.endpointUrl, this.color, this.theme});

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
  List<ModelCard> get cards{
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

    c.endpointTitle=json['endpointTitle'];
    c.endpointUrl=json['endpointUrl'];

    //TODO parse color
    //ep.color=colorList[i];
    var newcolor=json['color'];
    if (newcolor==null){

    } else if (newcolor=='red'){
      c.color=Colors.red;
    } else if (newcolor=='green'){
      c.color=Colors.green;
    }else if (newcolor=='orange'){
      c.color=Colors.orange;
    }else if (newcolor=='grey'){
      c.color=Colors.grey;
    }else if (newcolor=='yellow'){
      c.color=Colors.yellow;
    }else if (newcolor=='indigo'){
      c.color=Colors.indigo;
    }else if (newcolor=='pink'){
      c.color=Colors.pink;
    } else {
      c.color=Colors.deepPurple;
    }

    c.id=json['id'];
    c.name=json['name'];
    c.text=json['text'];

    c.images=List<String>.from(json['images']);

    c.fields=List<String>.from(json['fields']);
    c.stats=List<String>.from(json['stats']);
    c.tags=List<String>.from(json['tags']);
    c.related=json['related'];

    if (json['headers']!=null)
      c.headers=Map<String, String>.from(json['headers']);

    c.aboutWeb=json['aboutWeb'];
    c.aboutDoc=json['aboutDoc'];
    c.aboutInfo=json['aboutInfo'];
    c.aboutLogo=json['aboutLogo'];

    var tl=json['typeOfListing'];
    if (tl=='gridWithName')
      c.typeOfListing=TypeOfListing.gridWithName;
    else if (tl=='gridWithoutName')
      c.typeOfListing=TypeOfListing.gridWithoutName;
    else if (tl=='list')
      c.typeOfListing=TypeOfListing.list;

    var td=json['typeOfDetail'];
    if (td=='gridWithName')
      c.typeOfDetail=TypeOfDetail.detailsPage;
    else if (td=='productCompare')
      c.typeOfDetail=TypeOfDetail.productCompare;
    else if (td=='heroPage')
      c.typeOfDetail=TypeOfDetail.heroPage;
    else if (td=='match')
      c.typeOfDetail=TypeOfDetail.match;

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