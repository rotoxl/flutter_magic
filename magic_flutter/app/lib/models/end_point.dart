import 'dart:io';
import 'dart:ui';

import 'package:app/ui/widgets.dart';
import 'package:flutter/material.dart';

import 'package:app/models/model_card.dart';
import 'package:app/app_data.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum TypeOfListing{list, gridWithoutName, gridWithName, match}
enum TypeOfDetail{
  details,
  match,
  productCompare,
  hero //https://www.uplabs.com/posts/lonely-planet-hp-destination-selector
}

class EndPoint{
  static bool debug=false;

  TypeOfListing typeOfListing=TypeOfListing.gridWithName;
  TypeOfDetail typeOfDetail=TypeOfDetail.details;

  String endpointTitle;
  String endpointUrl;
  String endpointPath;

  List<Map<String, dynamic>> endpointParameters;
  Map<String, String> headers;
  String imagesProxy; //eg: https://images.weserv.nl/?url={url}
  String dependencies;//related endPoint for cross navigation

  List<String> categories=new List<String>();

  EPTheme epTheme;
  EPAbout about;

  String type="User";

  String id;
  EPTextWidget section; //just to group items
  EPNameWidget names;
  EPImagesWidget images;

  List<EPWidget> widgets=new List<EPWidget>();
  List<dynamic> widgetsOrder=new List<dynamic>();

  EndPoint({this.endpointTitle, this.endpointUrl});

  dynamic getWidgetByID(String id){
    for (var i=0;i<widgets.length;i++){
      var w=widgets[i];
      if (w.id==id){
        return w;
      } else if (w.fields.length>0){
        for (var j=0; j<w.fields.length; j++){
          var subw=w.fields[j];
          if (subw.id==id) {
            return subw;
          }
        }
      } else if (w.type==EPWidgetType.images){
        var ww=(w as EPImagesWidget);
        for (var j=0; j<ww.images.length; j++){
          var subw=ww.images[j];
          if (subw.id==id) {
            return subw;
          }
        }
      }
    }
    return null;
  }
  EPWidget getWidgetByType(EPWidgetType type){
    for (var i=0;i<widgets.length;i++){
      var w=widgets[i];
      if (w.type==type){
        return w;
      }
    }
    return null;
  }
//  List<String> allFields(){
//    //TODO dynamically load fields from 1st query
//
//    List<String> members= ["name", "manaCost", "type", "rarity", "set", "setName", "text", "artist", "number", "power", "toughness", "layout", "imageUrl", "originalText", "originalType", "id",
//    "cmc","multiverseid",
//    "colors", "colorIdentity", "types", "subtypes", "printings"];
//
//    return members;
//  }

  EPImage firstImageForListing() {
    return firstImageOfType(ImageType.thumbnail) ?? firstImageOfType(ImageType.image);
  }
  EPImage secondImageForListing() {
    return secondImageOfType(ImageType.thumbnail) ?? secondImageOfType(ImageType.image);
  }

  EPImage firstImageOfType(ImageType type){
    if (this.images==null) return null;
    return this.images.getFirstImageOfType(type);
  }
  EPImage secondImageOfType(ImageType type){
    if (this.images==null) return null;
    return this.images.getSecondImageOfType(type);
  }

  String firstName(){
    if (this.names==null)
      return null;
    return this.names.firstName();
  }
  secondName(){
    return this.names.secondName();
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

    AppData.debugPrintSection(EndPoint.debug, 'endpointTitle', json['endpointTitle']);
    c.endpointTitle=json['endpointTitle'];

    c.endpointUrl=json['endpointUrl'];
    AppData.debugPrint(debug, 'headers', json['headers']);
    if (json['headers']!=null)
      c.headers=Map<String, String>.from(json['headers']);

    AppData.debugPrint(debug, 'endpointParameters', json['endpointParameters']);
    if (json['endpointParameters']!=null)
      c.endpointParameters=List<Map<String, dynamic>>.from(json['endpointParameters']);

    if (json['imagesProxy']!=null)
      c.imagesProxy=json['imagesProxy'];

    if (json['endpointPath']!=null)
      c.endpointPath=json['endpointPath'];


    AppData.debugPrint(debug, 'dependencies', json['dependencies']);
    if (json['dependencies']!=null)
      c.dependencies=json['dependencies'];

    AppData.debugPrint(debug, 'theme', json['theme']);
    if (json['theme']!=null)
      c.epTheme=EPTheme.fromJson( json['theme'] );
    else {
      c.epTheme=EPTheme.randomTheme();
    }
    c.about=EPAbout.fromJson( json['about'] );

    c.id=json['id'];

    var nonWidgetKeys=['endpointTitle', 'endpointUrl', 'endpointPath', 'endpointParameters', 'imagesProxy', 'dependencies', 'theme','categories','type', 'typeOfListing', 'typeOfDetail', 'about','widgetsOrder','id',];

    EPWidget w;
    for (var i=0; i<json.keys.length; i++){
      var key=json.keys.toList()[i];

      if (nonWidgetKeys.contains(key) || key.startsWith("_"))
        continue;

      try{
        AppData.debugPrint(debug, key, json[key]);
        w=EPWidget.fromJson(key, json[key]);
      } catch (e){
        print (e);
        w=null;
      }

      if (w==null)
        continue;
      else if (w.type==EPWidgetType.images) //set up some shortcuts to special widgets
        c.images=w;
      else if (key=='name')
        c.names=w;
      else if (key=='section')
        c.section=w;

      w.id=key;
      c.widgets.add(w);
    }
    EndPoint.swallowWidgetsOrder(c, json['widgetsOrder']);

    var tl=json['typeOfListing'];
    if (tl=='gridWithName')
      c.typeOfListing=TypeOfListing.gridWithName;
    else if (tl=='gridWithoutName')
      c.typeOfListing=TypeOfListing.gridWithoutName;
    else if (tl=='list')
      c.typeOfListing=TypeOfListing.list;
    else if (tl=='match')
      c.typeOfListing=TypeOfListing.match;

    var td=json['typeOfDetail'];
    if (td=='detail')
      c.typeOfDetail=TypeOfDetail.details;
    else if (td=='productCompare')
      c.typeOfDetail=TypeOfDetail.productCompare;
    else if (td=='hero')
      c.typeOfDetail=TypeOfDetail.hero;
    else if (td=='match')
      c.typeOfDetail=TypeOfDetail.match;

    c.categories=List<String>.from(json['categories']);

    return c;
  }

  static void swallowWidgetsOrder(EndPoint c, List<dynamic> json) {
    if (json!=null){
      var list=List<Map<String, dynamic>>.from(json);
      for (var i=0; i<list.length; i++){
        var fila=list[i];

        var type=fila['type'];
        var id=fila['id'];

        dynamic w;

        if (id!=null){
            w=c.getWidgetByID(id);

        } else if (type=='hero' ||type==EPWidgetType.hero){
          w=new EPHeroWidget();

        } else if (type=='separator' || type==EPWidgetType.separator){
          w=new EPSeparatorWidget();

        } else if (type=='header' || type==EPWidgetType.header){
          w=new EPHeaderWidget.fromJson(fila, c);

        } else if (type=='images' || type==EPWidgetType.images){
          w=c.getWidgetByType(EPWidgetType.images);

        }

        if (w!=null){
          w.parent=c;
          c.widgetsOrder.add(w);
          }

      }
    }

  }
  EPWidgetType getTypeForString(String type) {
    if (type=='image' || type=='images'){
      return EPWidgetType.images;
    }
    else if (type=='tags'){
      return EPWidgetType.tags;
    }
    else if (type=='text'){
      return EPWidgetType.text;
    }
    else if (type=='stats'){
      return EPWidgetType.stats;
    }
    else if (type=='fields'){
      return EPWidgetType.fields;
    }

    return null;
  }

  ModelCard findCardById(String searchID) {
    for (ModelCard c in _cards){
      if (c.get(this.id)==searchID) return c;
    }
    return null;
  }

  Future<List<ModelCard>> fetchData({Map<String, String> parameters=null}) async {

    var tCall=new DateTime.now();

    AppData.debugPrint(debug, this.endpointTitle, null);
    String url=this.endpointUrl;

    if (parameters==null && endpointParameters!=null){
      //just use defaults
      parameters=Map<String, String>();
      this.endpointParameters.forEach((Map<String, dynamic> parMap){
        String key=parMap['name'];
        String v=parMap['value'].toString();

        parameters[key]=v;
      });
    }

    AppData.debugPrint(debug, "parameters", parameters);

    if (parameters!=null){
      parameters.forEach((String k, String v){
        url=url.replaceAll( '{'+k+'}', v);
      });
    }

    AppData.debugPrint (debug, 'Querying (${this.endpointTitle})', url);

    CacheManager.showDebugLogs = EndPoint.debug;
    var cacheManager = await CacheManager.getInstance();
    CacheManager.maxAgeCacheObject = new Duration(hours: 1);

    final file = await cacheManager.getFile(url, headers:this.headers);
    var response_body=file.readAsStringSync();

    var tResponse=new DateTime.now();
    // If the call to the server was successful, parse the JSON
    var jsonData=json.decode(response_body);
    var jsonCards;


    if (this.endpointPath!=null){
      List<String>temp=this.endpointPath.split('/');

      jsonCards=jsonData;
      for (int i=0; i<temp.length; i++){
        String key=temp[i];
        jsonCards=jsonCards[key];
      }

    }
    else {
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
    }

    var cards=List<ModelCard>();
    for (var i=0; i<jsonCards.length; i++){
      cards.add( ModelCard.fromJson(jsonCards[i]) );
    }

    var tProcessed=new DateTime.now();

    appData.logEvent('endpoint_load', {
      'title': this.endpointTitle,
      'time_to_load':tResponse.difference(tCall).inSeconds,
      'time_to_proccess':tProcessed.difference(tResponse).inSeconds,
      'number_of_cards':cards.length,
    });

    this.cards=cards;
    return cards;
//  } else {
//    // If that call was not successful, throw an error.
//    throw Exception('Failed to load post');
//  }
  }

  String proxiedImage(String url) {
    if (this.imagesProxy!=null){
      return this.imagesProxy.replaceAll('{url}', url);
    }
    else
      return url;
  }

//  Map<String, dynamic> toJson() => {
//    'title': endpointTitle,
//    'url': endpointUrl,
//
//    'id': id,
//    'name': name,
//    'text': text,
//
//    'images': images,
//    'stats': stats,
//    'tags': tags,
//    'fields': fields,
//
//    //'color': color,
//    'type': type,
//  };
//  List<HashMap<String, dynamic>> _values;
//  dynamic values(int rowNum, String field_id){
//    if (rowNum<0 || rowNum>=_values.length)
//      return null;
//
//    return _values[rowNum][field_id];
//  }
}
class EPTheme{
  ThemeData theme;
  Color color;

  EPTheme();

  factory EPTheme.fromJson(Map<String, dynamic> json) {
    var c=new EPTheme();

    if (json['color']!=null){
      var newcolor=json['color'];
      Color finalcolor;
      if (newcolor==null){
        finalcolor=randomColor();
      } else if (newcolor=='red'){
        finalcolor=Colors.red;
      } else if (newcolor=='green'){
        finalcolor=Colors.green;
      } else if (newcolor=='orange'){
        finalcolor=Colors.orange;
      } else if (newcolor=='grey'){
        finalcolor=Colors.grey;
      } else if (newcolor=='yellow'){
        finalcolor=Colors.yellow;
      } else if (newcolor=='indigo'){
        finalcolor=Colors.indigo;
      } else if (newcolor=='pink'){
        finalcolor=Colors.pink;
      } else if (newcolor=='brown'){
        finalcolor=Colors.brown;
      } else {
        finalcolor=Colors.deepPurple;
      }
      c.color=finalcolor;
    } else {
      c.color=Colors.grey[800];
    }

    if (json['base']=='dark'){
      c.theme=ThemeData.dark().copyWith(accentColor: c.color, buttonColor: c.color, primaryColor: c.color);
    }
    else {
      c.theme=ThemeData.light().copyWith(accentColor: c.color, buttonColor: c.color, primaryColor: c.color);
    }

    return c;
}

  static Color randomColor(){
    List<Color> colorList=[Colors.black, Colors.red, Colors.yellow, Colors.orange, Colors.green, Colors.blue, Colors.indigo, Colors.pink];
    var colorIndex=appData.endPoints().size;

    if (colorIndex>colorList.length-1)
      colorIndex=colorIndex % colorList.length;

    Color cc=colorList[colorIndex];
    return cc;
  }
  static EPTheme randomTheme() {
    var c=EPTheme();

    var cc=randomColor();
    c.theme=ThemeData.light().copyWith(accentColor:cc, primaryColor:cc);

    return c;
  }

}
class EPAbout{
  String web, doc, info, logo;

  EPAbout();

  factory EPAbout.fromJson(Map<String, dynamic> json) {
    var c=new EPAbout();

    c.web=json['web'];
    c.doc=json['doc'];
    c.info=json['info'];
    c.logo=json['logo'];

    return c;
  }

}

