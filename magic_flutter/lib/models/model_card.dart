import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:magic_flutter/models/end_point.dart';


class ModelCard{
  String id;
  Map<String, dynamic> json;
  //final Map rulings, legalities;

  final cacheExpresiones={};
  get(String expression){
    if (expression==null)
      return null;

    if (expression.indexOf("{")>-1){//es una expresión "{name}"
      var camposEncontrados=[];
      if (!cacheExpresiones.containsKey(expression)){
        var temp=expression.split("}");
        for (var i=0; i<temp.length; i++){
          var pos=temp[i].indexOf('{')+1;
          camposEncontrados.add(temp[i].substring(pos));
        }
        cacheExpresiones[expression]=camposEncontrados;
      }
      
      String ret=expression;
      camposEncontrados=cacheExpresiones[expression];
      for (var i=0; i<camposEncontrados.length; i++){
        String field=camposEncontrados[i];
        String mod=null;
        var newvalue;

        if (field.indexOf('|')>-1){ // campo|transformación
          var temp=field.split('|');
          field=temp[0];
          mod=temp[1];

          newvalue=json[field];
        } else if (field.indexOf('/')>-1){ // xPath
          var temp=field.split('/');

          try{
            newvalue=json;
            for (var j=0; j<temp.length; j++){
              newvalue=newvalue[temp[j]];
            }

          } catch(e){
            newvalue='Ruta xpath incorrecta';
          }
        }

        if (newvalue==null)
          newvalue="";

        if (mod==null){
          //pass
        } else if (mod=='lower'){
          newvalue=newvalue.toLowerCase();
        }

        ret=ret.replaceAll("{"+camposEncontrados[i]+"}", newvalue) ;
      }

      return ret.trim();

    } else {
      return json[expression];
    }
  }
  ModelCard({this.id});

  factory ModelCard.fromJson(Map<String, dynamic> json) {
    var c=ModelCard(id: json['id'].toString());

    c.json=json;
    return c;
  }
}

Future<List<ModelCard>> fetchPost(EndPoint ep) async {
  print ('Querying ${ep.endpointUrl}');

  var headers=ep.headers==null?{}:ep.headers;
  final response = await http.get(ep.endpointUrl, headers:headers);

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var jsonData=json.decode(response.body);
    var jsonCards;

    if (jsonData.runtimeType.toString()=='List<dynamic>'){
      jsonCards=jsonData;

    } else {
      var keys=jsonData.keys.toList();
      String finalkey;

      for (var i=0; i<keys.length; i++){
        var key=keys[i];
        try{
          var type=jsonData[ keys[i] ].runtimeType.toString();
          if (type=='List<dynamic>'){
            finalkey=key;
            break;
          }
        } catch (e){
        }
      }
      jsonCards=jsonData[finalkey];
    }

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

