import 'dart:async';
import 'dart:convert';
import 'package:app/app_data.dart';
import 'package:http/http.dart' as http;

import 'package:app/models/end_point.dart';


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
          if (temp[i].indexOf('{')>-1){
            var pos=temp[i].indexOf('{')+1;
            camposEncontrados.add(temp[i].substring(pos));
          }
        }
        cacheExpresiones[expression]=camposEncontrados;
      }
      
      String ret=expression;
      camposEncontrados=cacheExpresiones[expression];
      for (var i=0; i<camposEncontrados.length; i++){
        String field=camposEncontrados[i];
        String mod;
        var newvalue;

        if (field.indexOf('||')>-1){// campo||alternativa
          var temp=field.split('||');
          newvalue=json[temp[0]];

          if (newvalue==null || newvalue=='')
            newvalue=json[temp[1]];

          if (newvalue==null || newvalue=='')
            newvalue=null;
        }
        else if (field.indexOf('|')>-1){ // campo|transformación
          var temp=field.split('|');
          field=temp[0];
          mod=temp[1];

          newvalue=json[field];
        } else if (field.indexOf('/')>-1){ // xPath
          var temp=field.split('/');

          try{
            newvalue=json;
            for (var j=0; j<temp.length; j++){
              var key=temp[j];

              if (EPWidget.isNumeric(key)){
                var num=int.parse(key);
                newvalue=newvalue[num];
              } else {
                newvalue=newvalue[key];
              }
            }
            if (newvalue.runtimeType.toString()=='List<dynamic>'){
              //warn expresión no completa
//              newvalue=newvalue.toString();
            }

          } catch(e){
            return null;
          }
        } else{
          newvalue=json[field];
        }

        if (newvalue==null)
          newvalue="";

        if (mod==null){
          //pass
        } else if (mod=='lower'){
          newvalue=newvalue.toLowerCase();
        }

        ret=ret.replaceAll("{"+camposEncontrados[i]+"}", newvalue.toString()) ;
      }

      return ret.trim();

    } else {
      var newvalue;
      if (json.containsKey(expression))
        newvalue=json[expression];
      else
        newvalue=expression;//es un literal, un valor fijo: {valor}

      if (newvalue.runtimeType.toString()=='List<dynamic>')
        newvalue=newvalue[0];

      return newvalue;
    }
  }
  ModelCard({this.id});

  factory ModelCard.fromJson(Map<String, dynamic> json) {
    var c=ModelCard(id: json['id'].toString());

    c.json=json;
    return c;
  }

  static getImgPlaceholder() {
    return 'https://imgplaceholder.com/420x320/cccccc/757575/glyphicon-picture';
  }
}

Future<List<ModelCard>> fetchPost(EndPoint ep) async {
  var tCall=new DateTime.now();

  print ('Querying (${ep.endpointTitle}) --> ${ep.endpointUrl}');

  final response = await http.get(ep.endpointUrl, headers:ep.headers);
  if (response.statusCode == 200) {
    var tResponse=new DateTime.now();

    // If the call to the server was successful, parse the JSON
    var jsonData=json.decode(response.body);
    var jsonCards;
    var xtype=jsonData.runtimeType.toString();

    if (xtype=='List<dynamic>' || xtype.endsWith('List<dynamic>') ){
      jsonCards=jsonData;
    } else {

      var keys=jsonData.keys.toList();
      String finalkey;

      for (var i=0; i<keys.length; i++){
        var key=keys[i];
        try{
          var type=jsonData[ key ].runtimeType.toString();
          if (type=='List<dynamic>' || type.endsWith('List<dynamic>')){
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

    var tProcessed=new DateTime.now();

    appData.logEvent('endpoint_load', {
      'title': ep.endpointTitle,
      'time_to_load':tResponse.difference(tCall).inSeconds,
      'time_to_proccess':tProcessed.difference(tResponse).inSeconds,
      'number_of_cards':cards.length,
    });

    return cards;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

