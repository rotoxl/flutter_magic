import 'dart:math';
import 'dart:ui';
import 'package:app/ui/image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app/models/model_card.dart';
import 'package:app/app_data.dart';

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

  String endpointTitle;

  String endpointUrl;
  Map<String, String> headers;

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

  firstName(){
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

    c.endpointTitle=json['endpointTitle'];

    c.endpointUrl=json['endpointUrl'];
    if (json['headers']!=null)
      c.headers=Map<String, String>.from(json['headers']);

    if (json['theme']!=null)
      c.epTheme=EPTheme.fromJson( json['theme'] );
    else {
      c.epTheme=EPTheme.randomTheme();
    }
    c.about=EPAbout.fromJson( json['about'] );

    c.id=json['id'];

    var nonWidgetKeys=['endpointTitle','endpointUrl','theme','categories','type', 'typeOfListing', 'typeOfDetail', 'about','widgetsOrder','id',];

    for (var i=0; i<json.keys.length; i++){
      var key=json.keys.toList()[i];

      if (nonWidgetKeys.contains(key))
        continue;

      EPWidget w=EPWidget.fromJson(key, json[key]);
      if (w.type==EPWidgetType.images) //set up some shortcuts to special widgets
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

        }
        w.parent=c;
        if (w!=null)
          c.widgetsOrder.add(w);
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
      c.theme=ThemeData.dark().copyWith(accentColor: c.color, buttonColor: c.color);
    }
    else {
      c.theme=ThemeData.light().copyWith(accentColor: c.color, buttonColor: c.color);
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

enum EPWidgetType{
  name,

  images,
  tags,
  text,
  stats,
  fields,
  timeline,

  hero,
  header,
  separator
}
enum ImageType{
  poster, hero, thumbnail, image
}
enum NameType{
  left, right, name
}

abstract class EPWidget{
  final POSTER_RATIO = 0.7;
  final POSTER_HEIGHT= 140.0;
  final POSTER_WIDTH =100.0;

  final MARGIN_H=16.0;
  final MARGIN_V=8.0;

  EPWidgetType type;

  EndPoint parent;
  String id, field, title, subtitle, label, img;
  List<EPSubItem> fields=new List<EPSubItem>();

  ThemeData theme;
  TextTheme textTheme;

  String style; //one of subhead, title, null
  EPWidget();

  Widget containerLabel(String label){
    return Text(label, style: textTheme.caption.copyWith(fontSize:14.0), textAlign: TextAlign.start,);
  }

  setUpTheme(BuildContext context){
    this.theme=Theme.of(context);
    this.textTheme=this.theme.textTheme;
  }
  navigateImagePage(String url, BuildContext context){
    Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new ImagePage(url:url),
    ));
  }
  factory EPWidget.fromJson(String key, Map<String, dynamic> json) {
    var type=json['type'];
    if (type!=null){
      if (type=='stats')
        return EPStatsWidget.fromJson(json);
      else if (type=='images')
        return EPImagesWidget.fromJson(json);
      else if (type=='text')
        return EPTextWidget.fromJson(json);
      else if (type=='tags')
        return EPTagsWidget.fromJson(json);
      else if (type=='fields')
        return EPFieldsWidget.fromJson(json);
      else if (type=='hero')
        return EPHeroWidget.fromJson(json);
      else if (type=='timeline')
        return EPTimelineWidget.fromJson(json);
    }
    else if (key=='name'){
      return EPNameWidget.fromJson(json);
    }
    else
      return EPTextWidget.fromJson(json);
  }

  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth});

  String beautifulNumber(value){
    var orig=value;
    try{
      if (value.runtimeType.toString()=='int'){
        //pass
      }
      else{
        value=double.parse(value.toString());
      }
    } catch (e){
      return value.toString();
    }
    String ret; String unit='';
    if (value>1000000){
      ret=(value/1000000).toString().substring(0,3);
      unit="M";
    }
    else if (value>1000){
      ret=(value/1000).toString().substring(0,3);
      unit="K";
    }
    else if (value>100)
      ret=value.round().toString().substring(0,3);
    else{
      var t=value.toString();
      ret=t.substring(0, min(3, t.length) );
    }

    if (ret.endsWith('.0') ){
      ret=ret.substring(0, ret.length-2);
    } else if (ret.endsWith('.')){
      ret=ret.substring(0, ret.length-1);
    }

    print (orig.toString() + ' --> '+ret+unit);
    return ret+unit;

  }
}

abstract class EPSubItem{
  String id, label;
  String left, right, field;
}
class EPImage extends EPSubItem{
  ImageType type;

  EPImage();
}
class EPLabelText extends EPSubItem{
  NameType type;

  EPLabelText();
}

class EPTextWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.text;

  EPTextWidget();

  factory EPTextWidget.fromJson(Map<String, dynamic> json) {
    var c=EPTextWidget();

    if (json['field']!=null)    c.field=json['field'];
    if (json['title']!=null)    c.title=json['title'];
    if (json['subtitle']!=null) c.subtitle=json['subtitle'];

    if (json['label']!=null)    c.label=json['label'];
    if (json['img']!=null)      c.img=json['img'];

    if (json['fields']!=null){
      for (var i=0; i<json['fields'].length; i++){
        var fila=json['fields'][i];

        EPLabelText l=new EPLabelText();
        l.field=fila['field'];

        if (fila['id']!=null)
          l.id=fila['id'];

        l.type=NameType.name;
        c.fields.add(l);
      }

    }

    return c;
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);
    var wContent=<Widget>[];
    var textContent=<Widget>[];

    if (this.label!=null){
      textContent.addAll( [this.containerLabel(this.label), SizedBox(height: 8.0),]);
    }

    if (isLeft==null) isLeft=true;
    var align=isLeft? TextAlign.start: TextAlign.right;
    if (this.title!=null){
      var t=card.get(this.title);
      textContent.add( Text(t, style:this.textTheme.body1, textAlign: align,));

      if (this.subtitle!=null){
        var t=card.get(this.subtitle);
        textContent.add( Text(t, style:this.textTheme.body2.copyWith(color: Colors.grey), textAlign: align, ));
      }
    } else if (this.field!=null){
      var t=card.get(this.field);
      textContent.add( Text(t, style:this.textTheme.body1, textAlign: align,));
    }

    wContent.add(
        Expanded(flex:2, child:Column(children: textContent, crossAxisAlignment: CrossAxisAlignment.start,))
    );

    if (this.img!=null){
      String url=card.get(this.img);

      var height = POSTER_RATIO * POSTER_WIDTH;

      var img=CachedNetworkImage(imageUrl: url, placeholder: new CircularProgressIndicator(),fit: BoxFit.fitHeight, width: POSTER_WIDTH, height: height,);
      var boxedImage=Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: img);

      var domImage=Expanded(
          flex:1,
          child:GestureDetector(
            child:boxedImage,
            onTap: () {
              navigateImagePage(url, context);
            },
          )
      );

      wContent.add(domImage);
    }

    return Container(
      padding:EdgeInsets.symmetric(horizontal:MARGIN_H, vertical:MARGIN_V),
      child:Row(children: wContent)
    );
  }
}

class EPFieldsWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.fields;

//  List<_EPLabelText> fields=new List<_EPLabelText>();

  EPFieldsWidget();
  factory EPFieldsWidget.fromJson(Map<String, dynamic> json) {
    var c=EPFieldsWidget();
    return reusableFactory(c, json);
  }
  static reusableFactory(EPFieldsWidget c, Map<String, dynamic> json) {
    c.label=json['label'];

    var l=List<dynamic>.from(json['fields']);
    for (var i=0; i<l.length; i++){
      var fila=l[i];
      if (fila.runtimeType.toString()=='String'){
        var e=new EPLabelText();
        e.field=fila;
        c.fields.add(e);
      }
      else {
        var item=Map<String, String>.from(l[i]);

        if (item['field']!=null){
          var e=new EPLabelText();
          e.label=item['label'];
          e.field=item['field'];

          c.fields.add(e);
        } else {
          var e=new EPLabelText();

          e.id=item['id'];
          e.label=item['label'];
          c.fields.add(e);

          if (item['left']!=null)e.left=item['left'];
          if (item['right']!=null) e.right=item['right'];
        }

      }
    }
    return c;
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}){
    setUpTheme(context);

    var sec = <Widget>[];

    if (this.label!=null)
      sec.add( this.containerLabel(this.label) );

    for (int i=0; i<this.fields.length; i++){
      var field=this.fields[i];

      if (this.parent.typeOfDetail==TypeOfDetail.match){

        if (field.label=='separator'){
          sec.add(SizedBox(height:18.0));

        } else {
          var value1 = beautifulNumber(card.get(field.left));
          var value2 = beautifulNumber(card.get(field.right));

          sec.add( _valueLabelValue(value1, field.label, value2));
        }

      } else {
        var value=beautifulNumber(card.get(field.field));

        if (value==null)
          continue;
        else if (value.runtimeType.toString()=='List<dynamic>')
          value=value[0];

        try{
          sec.add(
            new ListTile(
              contentPadding: EdgeInsets.only(left:0.0, right:0.0),
              title:Text(value),
              subtitle: Text(field.label),
              trailing: Icon(Icons.edit_attributes, color: theme.primaryColor)
            )
          );
        } catch(e, s){
        }

      }
    }

    return Container(
        //width:MediaQuery.of(context).size.width,
        margin:EdgeInsets.only(left:MARGIN_H, right:MARGIN_H, top:MARGIN_V),
        child:new Column(children:sec, crossAxisAlignment: CrossAxisAlignment.start,)
    );
  }
  Widget generateWidgetCompare(BuildContext context, ModelCard card, ModelCard cardToCompare) {
    setUpTheme(context);

    var sec = <Widget>[];

    if (this.label!=null)
      sec.add( this.containerLabel(this.label) );

    for (int i=0; i<this.fields.length; i++){
      var field=this.fields[i];

      if (field.label=='separator'){
        sec.add(SizedBox(height:18.0));

      } else {
        var value1 = beautifulNumber(card.get(field.field));
        var value2 = beautifulNumber(cardToCompare.get(field.field));

        sec.add( _valueLabelValue(value1, field.label, value2));
      }
    }

    return Container(
      //width:MediaQuery.of(context).size.width,
        margin:EdgeInsets.only(left:0, right:0, top:MARGIN_V),
        child:new Column(children:sec, crossAxisAlignment: CrossAxisAlignment.start,)
    );
  }
  Widget _valueLabelValue(value1, att_text, value2){
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: new Row(
        children: <Widget>[
          new Expanded(child: new Text(value1,   textAlign: TextAlign.left, style: textTheme.subhead),
          ),
          new Expanded(child: new Text(att_text, textAlign: TextAlign.center, style: textTheme.caption,),
          ),
          new Expanded(child: new Text(value2, textAlign: TextAlign.right, style: textTheme.subhead),
          ),
        ],
      ),
    );
  }
}
class EPTagsWidget extends EPFieldsWidget{
  EPWidgetType type=EPWidgetType.tags;

  EPTagsWidget();
  factory EPTagsWidget.fromJson(Map<String, dynamic> json) {
    var c=EPTagsWidget();
    return EPFieldsWidget.reusableFactory(c, json);
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}){
    setUpTheme(context);

    var ret=<String>[];

    for (var i=0; i<this.fields.length; i++){
      var field=this.fields[i];
      var values=card.get(field.field);

      if (values==null || values==''){
        //pass
      }
      else if (values.runtimeType.toString()=='String'){
        if (values.indexOf(',')>-1){
          var temp=values.split(',');
          for (var j=0; j<temp.length; j++){
            ret.add( temp[j].toString().trim() );
          }
        }
        else
          ret.add(values);
      }
      else {
        for (var j=0; j<values.length; j++) {
          var value=values[j];
          ret.add(value);
        }
      }
    }

    var c= <Widget>[];
    if (this.label!=null){
      c.addAll([
        Container(child:this.containerLabel(this.label), padding: EdgeInsets.only(left:MARGIN_H)),
        SizedBox(height: 8.0),
      ]);
    }

    var lvw=ListView.builder(
      itemCount: ret.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(top: 0.0, left: MARGIN_H),
      itemBuilder: (BuildContext, index) => _buildChip(ret[index]),
    );

    c.add(Container(child:lvw, height: 35.0, width: maxWidth?? 400.0,));

    return Container(
        padding:EdgeInsets.only(top:MARGIN_V),
        child: Column(children: c, crossAxisAlignment: CrossAxisAlignment.start,)
    );
  }
  Widget _buildChip(String value) {
    return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Chip(
          label: Text(value),
          labelStyle: this.textTheme.caption,
          backgroundColor: Colors.black12,
        ),
      );
  }
}

class EPStatsWidget extends EPFieldsWidget{
  EPWidgetType type=EPWidgetType.tags;

  EPStatsWidget();
  factory EPStatsWidget.fromJson(Map<String, dynamic> json) {
    var c=EPStatsWidget();
    return EPFieldsWidget.reusableFactory(c, json);
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}){
    setUpTheme(context);

    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.primaryColor,);
    var themeSoft = textTheme.caption;

    var ret=<Widget>[];
    for (var i=0; i<this.fields.length; i++){
      var field=this.fields[i];

      if (i>0) ret.add( SizedBox(width: MARGIN_H) );

      CrossAxisAlignment align=CrossAxisAlignment.center;
      if (i==0)
        align=CrossAxisAlignment.start;
      else if (i==this.fields.length-1)
        align=CrossAxisAlignment.end;
      else
        align=CrossAxisAlignment.center;

      var value=beautifulNumber( card.get(field.field) );

      var numericRating = Column(
        crossAxisAlignment: align,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: themeBold, textAlign: TextAlign.center,),
          SizedBox(height: 4.0),
          Text(field.label, style: themeSoft,),
        ],
      );

      ret.add(numericRating);
    }

    return Container(
        height: 50.0,
        width: maxWidth?? 400.0,

        child:ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 0.0, left: 0.0),
          itemBuilder: (BuildContext, index) => ret[index],
        )
    );
  }
}
class EPNameWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.name;
//  List<_EPLabelText> fields=new List<_EPLabelText>();

  EPNameWidget();
  factory EPNameWidget .fromJson(Map<String, dynamic> json) {
    var c=new EPNameWidget();
//    if (json['left']!=null){
//      var c=json['left'];
//
//      _EPLabelText l=new _EPLabelText(c['field'], null);
//      l.type=NameType.left;
//      c.fields.add(l);
//
//    }
//    if (json['right']!=null){
//      var c=json['left'];
//
//      var l=new _EPLabelText();
//      l.field=c['field'];
//      l.type=NameType.right;
//
//      c.fields.add(l);
//    }

    if (json['field']!=null){
      EPLabelText l=new EPLabelText();
      l.field=json['field'];
      l.type=NameType.name;
      c.fields.add(l);
    }

    if (json['fields']!=null){
      for (var i=0; i<json['fields'].length; i++){
        var fila=json['fields'][i];

        EPLabelText l=new EPLabelText();
        l.field=fila['field'];

        if (fila['id']!=null)
          l.id=fila['id'];

        l.type=NameType.name;
        c.fields.add(l);
      }

    }
    return c;
  }
  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    String texto;
    if (this.fields.length>0){
      texto=card.get(this.fields[0].field) ;
    }

    if (isLeft==null) isLeft=true;

    var t=Theme.of(context);
    var align=isLeft? TextAlign.start: TextAlign.right;
    if (this.type==EPWidgetType.name){
      return Text(texto, style: t.textTheme.title.copyWith(color:t.accentColor), maxLines: 3, overflow: TextOverflow.ellipsis, textAlign:align,);
    } else {
      return Text(texto, style: this.textTheme.display1, textAlign:align,);
    }

  }

  firstName() {
    return _getNtht(0).field;
  }
  secondName() {
    return _getNtht(1).field;
  }
//  leftName(){
//    var f=_getBySide(NameType.left);
//    if (f!=null)
//      return f.field;
//  }
//  rightName(){
//    var f=_getBySide(NameType.right);
//    if (f!=null)
//      return f.field;
//  }
//  _EPLabelText _getBySide(NameType side){
//    for (var i=0; i<this.fields.length; i++){
//      var f=this.fields[i];
//      if (f.type==side)
//        return f;
//    }
//  }
  EPLabelText _getNtht(int index){
//    for (var i=0; i<this.fields.length; i++){
//      var f=this.fields[i];
//      return f.field;
//    }
    return this.fields[index];
  }
}
class EPImagesWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.images;

  List<EPImage> images=new List<EPImage>();

  EPImagesWidget();
  factory EPImagesWidget.fromJson(Map<String, dynamic> json) {
    var c=EPImagesWidget();

    var l=List< dynamic >.from(json['fields']);
    for (var i=0; i<l.length; i++){
      var fila=l[i];

      var ei=EPImage();
      if (fila.runtimeType.toString()=='String'){
        ei.type=ImageType.image;
        ei.field=fila;
      }
      else {
        var t={'image':ImageType.image, 'hero':ImageType.hero, 'poster':ImageType.poster, 'thumbnail':ImageType.thumbnail}[ fila['type'] ];
        ei.type=t;
        ei.field=fila['field'];
      }

      c.images.add(ei);
      if (fila['id']!=null)
        ei.id=fila['id'];
    }
    return c;
  }
  EPImage getFirstImageOfType(ImageType s){
    if (s != ImageType.image)
      return _getNthtImageOfType(s, 0) ?? _getNthtImageOfType(ImageType.image, 0);
    else
      return this.images[0];
  }
  EPImage getSecondImageOfType(ImageType s){
    if (s != ImageType.image)
      return _getNthtImageOfType(s, 1) ?? _getNthtImageOfType(ImageType.image, 1);
    else if (this.images.length>1)
      return this.images[1];
    else
      return null;
  }
  EPImage _getNthtImageOfType(ImageType s, int index){
    var count=0;
    for (var i=0; i<this.images.length; i++){
      var img=this.images[i];

      if (count==index){
        return img;
      }
      if (img.type==s){
        count++;
      }
    }
  }

  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}){
    setUpTheme(context);

    var ret=<String>[];
    for (var i=0; i<this.images.length; i++){
      var f=this.images[i];
      var values=card.get(f.field);

      if (values==null){
//        //pass
      }
      else if (values.runtimeType.toString()=='String'){
        ret.add(values);
      }
      else {
        for (var j=0; j<values.length; j++) {
          var value=values[j];
          ret.add(value);
        }
      }
      return _buildPhotoScrollerList(context, ret);
    }
  }
  Widget generateWidgetCompare(BuildContext context, ModelCard card, ModelCard cardToCompare) {
    setUpTheme(context);

    var ret=<String>[];
    for (var i=0; i<this.images.length; i++){
      var f=this.images[i];

      for (var j=0; j<2; j++){
        var values;
        if (j==0)
          values=card.get(f.field);
        else
          values=cardToCompare.get(f.field);

        if (values==null){
        }
        else if (values.runtimeType.toString()=='String'){
          ret.add(values);
        }
        else {
          for (var j=0; j<values.length; j++) {
            var value=values[j];
            ret.add(value);
          }
        }
      }
      return _buildPhotoScrollerList(context, ret);
    }
  }

  Widget _buildPhotoScrollerList(BuildContext context, List<String> ret){
    return SizedBox.fromSize(
        size: Size.fromHeight(POSTER_HEIGHT+40.0),
        child: ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(top: MARGIN_V, left: MARGIN_H),
          itemBuilder: (BuildContext, index) => _buildPhotoScrollerItem(context, ret[index]),
        )
    );
  }
  Widget _buildPhotoScrollerItem(BuildContext context, String url){
    if (url=='') return null;

    var el=Padding(
      padding: new EdgeInsets.only(right: MARGIN_H, top:MARGIN_V),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(imageUrl: url, placeholder: new CircularProgressIndicator(), height: POSTER_HEIGHT, fit: BoxFit.scaleDown,),
      ),
    );

    return GestureDetector(
      child:el,
      onTap: () {
        navigateImagePage(url, context);
      },
    );
  }
}

class EPHeroWidget extends EPWidget{
  final HERO_HEIGHT = 156.0;
  EPWidgetType type=EPWidgetType.hero;

  EPHeroWidget();

  generateWidgetCompare(BuildContext context, ModelCard card, ModelCard cardToCompare) {
    return null;
  }
  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    return null;
  }
  factory EPHeroWidget.fromJson(Map<String, dynamic> json) {
    var c=EPHeroWidget();
    return c;
  }
}
class EPTimelineWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.timeline;

//  List<_EPLabelText> fields=new List<_EPLabelText>();
  String transform, sort;
  List<String>sort_strip=new List<String>();

  EPTimelineWidget();
  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    List<dynamic> data=_getData(card);
    List<Widget> children=new List<Widget>();
    if (this.label!=null){
      children.addAll( [this.containerLabel(this.label), SizedBox(height: 8.0),]);
    }
    children.addAll(_timeLineWidget(context, data));

    return Container(
        height: 60.0*(data.length+1),
//        width: MediaQuery.of(context).size.width,
        padding:EdgeInsets.symmetric(vertical:MARGIN_V),
        child:Column(children: children,)
    );

  }

  List<Widget> _timeLineWidget(BuildContext context, List<dynamic> data){
    var rowHeight=60.0;
    var screenWidth=MediaQuery.of(context).size.width;

    var centerColWidth=40.0;
    var colWidth=(screenWidth-centerColWidth)/2;

    var l=<Widget>[];

    for (var i=0;i<data.length; i++){
      var fila=data[i];

      Container leftCol=new Container(width:colWidth); Container rightCol=new Container(width:colWidth);
      var centerCol; var colItems;

      colItems=[
        Text(fila['time'], style:textTheme.caption),
        Text(fila['type_of_event'], style:textTheme.caption ),
        Expanded(child:Text(fila['player'], style:textTheme.subhead, overflow: TextOverflow.fade, maxLines: 1, softWrap: false,)),
      ];

      if (fila['side']=='left') {//isIzq
        leftCol=new Container(width:colWidth, child:new Column(children: colItems, crossAxisAlignment: CrossAxisAlignment.end),);
      } else {
        rightCol=new Container(width:colWidth, child:new Column(children: colItems, crossAxisAlignment: CrossAxisAlignment.start));
      }

      double bulletTop=rowHeight/4;
      double lineStart=0.0, lineEnd=rowHeight;
      if (i==0){
        lineStart=bulletTop;
        lineEnd=rowHeight-lineStart;
      }
      else if (i==data.length-1){
        lineStart=0.0;
        lineEnd=bulletTop;
      }

      centerCol=new Container(height: rowHeight, width:centerColWidth, child: new Stack(children: <Widget>[
            new Positioned(
              top: lineStart, height: lineEnd, left: 25.0,
              child: new Container(height: 20.0, width: 1.0, color: Colors.grey),
            ),
            new Positioned(
              top: bulletTop-8.0, left: 16.0,
              child: new Container(
                margin: new EdgeInsets.all(5.0),
                height: 10.0, width: 10.0,
                decoration: new BoxDecoration(shape: BoxShape.circle,color: theme.accentColor),
                ),
              )
          ])
        );

      l.add(new Container(height:rowHeight, width:screenWidth, child:new Row(children: <Widget>[leftCol, centerCol, rightCol] )));

    }
  return l;
  }
  List<dynamic> _getData(ModelCard card){
    List<dynamic>timelinedata=[];

    for (var j=0; j<this.fields.length; j++){
      var field=this.fields[j];
      List<dynamic>newdata=card.get(field.field);

      for (var i=0; i<newdata.length; i++){
        if (this.transform=='left/right'){
          newdata[i]['side']= (i==0?'left':'right');
        }
      }
      timelinedata.addAll(newdata);
    }

    if (this.sort!=null){
      var whichField=this.sort;

      timelinedata.sort((a,b){
        var vala=a[whichField].toString();
        var valb=b[whichField].toString();

        if (this.sort_strip!=null){
          List<String> l=this.sort_strip;

          for (var i=0; i<l.length; i++){
            vala=vala.replaceAll(l[i], '');
            valb=valb.replaceAll(l[i], '');
          }
        }

        if (isNumeric(vala) && isNumeric(valb)){
          var numa=int.parse(vala);
          var numb=int.parse(valb);

          return numa.compareTo(numb);
        } else {
          return vala.compareTo(valb);
        }
      });
    }

    return timelinedata;
  }
  factory EPTimelineWidget.fromJson(Map<String, dynamic> json) {
    var c=EPTimelineWidget();

    var l=List<dynamic>.from(json['fields']);
    for (var i=0; i<l.length; i++){
      var fila=l[i];
      if (fila.runtimeType.toString()=='String'){
        var l=EPLabelText();
        l.field=fila;
        c.fields.add(l);
      }
    }
    if (json['transform']!=null)
      c.transform=json['transform'];

    if (json['sort']!=null){
      c.sort=json['sort'];

      if (json['sort_strip']!=null)
        c.sort_strip=List<String>.from(json['sort_strip']);
    }

    return c;
  }
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
class EPSeparatorWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.separator;

  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: MARGIN_V),
      // color:Colors.red,
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
      ),
    );
  }
  Widget generateWidgetCompare(BuildContext context, ModelCard card, ModelCard cardToCompare){
    return generateWidget(context, card);
  }
}
class EPHeaderWidget extends EPWidget{

  EPWidgetType type=EPWidgetType.header;

  List<dynamic> left=new List<dynamic>();
  List<dynamic> right=new List<dynamic>();

  EPHeaderWidget();
  factory EPHeaderWidget.fromJson(Map<String, dynamic> json, EndPoint parent) {
    var c=EPHeaderWidget();
    if (parent!=null) c.parent=parent;

    if (json['left']!=null)
      c.left=eatIt(c.parent, json['left']);
    if (json['right']!=null)
      c.right=eatIt(c.parent, json['right']);

    return c;
  }
  static eatIt(EndPoint c, dynamic json) {
    var ret=List<dynamic>();

    var l=List<dynamic>.from(json);
    for (var i=0; i<l.length; i++){
      var fila=l[i];

      var type=fila['type'];
      var id=fila['id'];

      if (id!=null){
        dynamic w=c.getWidgetByID(id);
        ret.add(w);

      } else if (type!=null){
        var xtype=c.getTypeForString(type);
        EPWidget w=c.getWidgetByType(xtype);

        ret.add(w);
      }
    }
    return ret;
  }
  Widget generateWidgetCompare(BuildContext context, ModelCard card, ModelCard cardToCompare){
    setUpTheme(context);

    var MARGIN_H=16.0;

    var l=thisSide(context, card, this.left, true);
    var r=thisSide(context, cardToCompare, this.right, false);

    var content=<Widget>[l, SizedBox(width: MARGIN_H), r];
    return _wrapRow(content);
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    var MARGIN_H=16.0;

    var l=thisSide(context, card, this.left, true);
    var r=thisSide(context, card, this.right, false);

    var content=<Widget>[l, SizedBox(width: MARGIN_H), r];
    return _wrapRow(content);
  }
  Widget _wrapRow(List<Widget> content){
    return Stack(
        alignment: AlignmentDirectional.centerStart,
        children:[
          Padding(padding: const EdgeInsets.only(bottom: 200.0)),
          Positioned(
              left:MARGIN_H, right:MARGIN_H, bottom:MARGIN_V,
              child:Row(
//            crossAxisAlignment: CrossAxisAlignment.end,
//            mainAxisAlignment: MainAxisAlignment.end,
                children: content,
              )
          ),
        ]
    );
  }

  Widget thisSide(BuildContext context, ModelCard card, List<dynamic> list, bool isLeft){
    var ret=List<Widget>();
    for (var i=0; i<list.length; i++){
      var fila=list[i];
      Widget w;

      if (fila is EPSeparatorWidget){
        w=SizedBox(height:MARGIN_V);
      } else if (fila is EPImage){
        print ('is subitem');

        String url=card.get(fila.field);
        w = poster(context, url, isLeft);
      } else if (fila is EPLabelText){
        String texto=card.get(fila.field);
        w=Text(texto, style: Theme.of(context).textTheme.title, maxLines: 3, overflow: TextOverflow.ellipsis,);

      } else if (fila is EPWidget){
        print ('is EPWidget');

        if (fila.parent==null)
          fila.parent=this.parent;

        if (fila.type==EPWidgetType.images) {
          EPImage field = this.parent.firstImageOfType(ImageType.poster);
          String url = card.get(field.field);
          w = poster(context, url, isLeft);
        } else if (fila.type==EPWidgetType.separator){
          w=SizedBox(height:MARGIN_V);
        } else {
          w=fila.generateWidget(context, card, isLeft:isLeft);
        }

      }

      if (w!=null){
        ret.add(w);
        //if (i<list.length-1) ret.add(SizedBox(height: MARGIN_V));
      }

    }
    if (ret.length==1)
      return ret[0];
    else {
      return Expanded(
        flex:1,
        child: Column(
          crossAxisAlignment: (isLeft?CrossAxisAlignment.start:CrossAxisAlignment.end),
          children: ret
        )
      );
    }
  }
  Widget poster(BuildContext context, String url, bool isLeft){
    var width = POSTER_WIDTH;
    var height= POSTER_HEIGHT;

    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
    var domImage=CachedNetworkImage(imageUrl:url, placeholder: new CircularProgressIndicator(), fit: doesNotWantsBox?BoxFit.contain:BoxFit.cover, height: height, );

    return GestureDetector(
        child:doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
        onTap: () {
            navigateImagePage(url, context);
        },
    );
  }
//  static procArg(dynamic param){
//    var xtype=param.runtimeType.toString();
//    if (xtype=='List<dynamic>' || xtype.endsWith('List<dynamic>') ){
//
//    } else {
//      return
//    }
//  }
}
