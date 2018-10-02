import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:app/models/model_card.dart';

enum TypeOfListing{list, gridWithoutName, gridWithName, match}
enum TypeOfDetail{
  details,
  match,
  productCompare,
  hero //https://www.uplabs.com/posts/lonely-planet-hp-destination-selector
}

class EndPoint{
  TypeOfListing typeOfListing=TypeOfListing.gridWithName;
  TypeOfDetail typeOfDetail=TypeOfDetail.details;

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

  String section; //group items

  //detailType=match
  var names=List<String>();

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

  firstName(){
    if (names.length==0)
      return name;
    else
      return names[0];
  }
  secondName(){
    if (names.length==0)
      return null;
    else
      return names[1];
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

    if (json['theme']=='dark'){
      c.theme=ThemeData.dark().copyWith(accentColor: Colors.grey[800], buttonColor: Colors.grey[800]);
    } else {
      var newcolor=json['color'];
      Color finalcolor;
      if (newcolor==null){

      } else if (newcolor=='red'){
        finalcolor=Colors.red;
      } else if (newcolor=='green'){
        finalcolor=Colors.green;
      }else if (newcolor=='orange'){
        finalcolor=Colors.orange;
      }else if (newcolor=='grey'){
        finalcolor=Colors.grey;
      }else if (newcolor=='yellow'){
        finalcolor=Colors.yellow;
      }else if (newcolor=='indigo'){
        finalcolor=Colors.indigo;
      }else if (newcolor=='pink'){
        finalcolor=Colors.pink;
      } else if (newcolor=='brown'){
        finalcolor=Colors.brown;
      } else {
        finalcolor=Colors.deepPurple;
      }
      c.color=finalcolor;
    }

    c.id=json['id'];
    c.name=json['name'];
    c.text=json['text'];

    c.images=List<String>.from(json['images']);

    c.fields=List<String>.from(json['fields']);
    c.stats=List<String>.from(json['stats']);

    if (json['tags']!=null)
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
      c.typeOfDetail=TypeOfDetail.details;
    else if (td=='productCompare')
      c.typeOfDetail=TypeOfDetail.productCompare;
    else if (td=='heroPage')
      c.typeOfDetail=TypeOfDetail.hero;
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