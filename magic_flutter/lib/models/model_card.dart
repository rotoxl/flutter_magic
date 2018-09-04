import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:magic_flutter/models/end_point.dart';


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

Future<List<ModelCard>> fetchPost(EndPoint ep) async {
  final response = await http.get(ep.url);

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

