import 'dart:math';
import 'dart:ui';
import 'package:app/ui/image_page.dart';
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

  List<String> categories;

  EPTheme epTheme;
  EPAbout about;

  String type="User";

  String id;
  EPTextWidget section; //just to group items
  EPNameWidget names;
  EPImagesWidget images;

  List<EPWidget> _widgets=new List<EPWidget>();
  List<EPWidget> widgetsOrder=new List<EPWidget>();

  EndPoint({this.endpointTitle, this.endpointUrl});

  EPWidget getWidgetByID(String id){
    for (var i=0;i<_widgets.length;i++){
      var w=_widgets[i];
      if (w.id==id){
        return w;
      }
    }
    return null;
  }
  EPWidget getWidgetByType(EPWidgetType type){
    for (var i=0;i<_widgets.length;i++){
      var w=_widgets[i];
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
      c._widgets.add(w);
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

    return c;
  }

  static void swallowWidgetsOrder(EndPoint c, List<dynamic> json) {
    if (json!=null){
      var list=List<Map<String, dynamic>>.from(json);
      for (var i=0; i<list.length; i++){
        var fila=list[i];

        var type=fila['type'];
        var id=fila['id'];

        EPWidget w;

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

    if (json['theme']=='dark'){
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

  ThemeData theme;
  TextTheme textTheme;

  EPWidget();

  Widget containerLabel(String label){
    return Text('Desc', style: textTheme.caption.copyWith(fontSize:14.0, color: Color(0x8a000000)), textAlign: TextAlign.start,);
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

class EPImage{
  ImageType type;
  String field;
  EPImage(this.type, this.field);
}
class _EPLabelText{
  String field, label;
  NameType type;
  _EPLabelText(this.field, this.label);
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

    return c;
  }
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);
    var wContent=<Widget>[];
    var textContent=<Widget>[];

    if (this.label!=null){
      textContent.addAll( [this.containerLabel(this.label), SizedBox(height: 8.0),]);
    }

    if (this.title!=null){
      var t=card.get(this.title);
      textContent.add( Text(t, style:this.textTheme.body1));

      if (this.subtitle!=null){
        var t=card.get(this.subtitle);
        textContent.add( Text(t, style:this.textTheme.body2.copyWith(color: Colors.grey) ));
      }
    } else if (this.field!=null){
      var t=card.get(this.field);
      textContent.add( Text(t, style:this.textTheme.body1));
    }

    wContent.add(
        Expanded(flex:2, child:Column(children: textContent, crossAxisAlignment: CrossAxisAlignment.start,))
    );

    if (this.img!=null){
      String url=card.get(this.img);

      var height = POSTER_RATIO * POSTER_WIDTH;

      var img=new Image.network(url, fit: BoxFit.fitHeight, width: POSTER_WIDTH, height: height,);
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
  EPWidgetType type=EPWidgetType.stats;

  List<_EPLabelText> fields=new List<_EPLabelText>();

  EPFieldsWidget();
  factory EPFieldsWidget.fromJson(Map<String, dynamic> json) {
    var c=EPFieldsWidget();
    return reusableFactory(c, json);
  }
  static reusableFactory(EPFieldsWidget c, Map<String, dynamic> json) {
    var l=List<dynamic>.from(json['fields']);
    for (var i=0; i<l.length; i++){
      var fila=l[i];
      if (fila.runtimeType.toString()=='String'){
        c.fields.add(_EPLabelText( fila, null ));
      }
      else {
        var item=Map<String, String>.from(l[i]);
        c.fields.add(_EPLabelText( item['field'], item['label'] ));
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
      var value=card.get(field.field);

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

    return Container(
        //width:MediaQuery.of(context).size.width,
        margin:EdgeInsets.only(left:MARGIN_H, right:MARGIN_H, top:MARGIN_V),
        child:new Column(children:sec, crossAxisAlignment: CrossAxisAlignment.start,)
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

    return Container(
        height: 40.0,
        width: maxWidth?? 400.0,
        child: ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 0.0, left: 0.0),
          itemBuilder: (BuildContext, index) => _buildChip(ret[index]),
        )
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
  List<_EPLabelText> fields=new List<_EPLabelText>();

  EPNameWidget();
  factory EPNameWidget .fromJson(Map<String, dynamic> json) {
    var c=new EPNameWidget();
    if (json['left']!=null){
      var c=json['left'];

      _EPLabelText l=new _EPLabelText(c['field'], null);
      l.type=NameType.left;
      c.fields.add(l);

    }
    if (json['right']!=null){
      var c=json['left'];

      _EPLabelText l=new _EPLabelText(c['field'], null);
      l.type=NameType.right;
      c.fields.add(l);
    }
    if (json['field']!=null){
      _EPLabelText l=new _EPLabelText(json['field'], null);
      l.type=NameType.name;
      c.fields.add(l);
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

    if (this.type==EPWidgetType.name){
      return Text(texto, style: Theme.of(context).textTheme.title, maxLines: 3, overflow: TextOverflow.ellipsis,);
    } else {
      return Text(texto, style: this.textTheme.display1, );
    }

  }

  firstName() {
    return _getNtht(0).field;
  }
  secondName() {
    return _getNtht(1).field;
  }
  leftName(){
    var f=_getBySide(NameType.left);
    if (f!=null)
      return f.field;
  }
  rightName(){
    var f=_getBySide(NameType.right);
    if (f!=null)
      return f.field;
  }
  _EPLabelText _getBySide(NameType side){
    for (var i=0; i<this.fields.length; i++){
      var f=this.fields[i];
      if (f.type==side)
        return f;
    }
  }
  _EPLabelText _getNtht(int index){
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

      if (fila.runtimeType.toString()=='String'){
        c.images.add(EPImage( ImageType.image, fila ));
      }
      else {
        var t={'image':ImageType.image, 'hero':ImageType.hero, 'poster':ImageType.poster, 'thumbnail':ImageType.thumbnail}[ fila['type'] ];
        c.images.add( new EPImage(t, fila['field']));
      }
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
    return _getNthtImageOfType(s, 1);
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

    return Container(
        margin:EdgeInsets.only(left:MARGIN_H, right:MARGIN_H, bottom:8.0, top:2.0),
        color:Colors.orange,
        child:Text(this.type.toString())
    );
  }
  _buildPhotoScrollerItem(BuildContext context, String url){
    if (url=='') return null;

    var el=Padding(
      padding: new EdgeInsets.only(right: MARGIN_H, top:MARGIN_V),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.network(url, height: POSTER_HEIGHT, fit: BoxFit.scaleDown,),
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

  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    return null;
  }
  factory EPHeroWidget.fromJson(Map<String, dynamic> json) {
    var c=EPHeroWidget();
    return c;
  }
}
class EPSeparatorWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.separator;

  @override
  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: MARGIN_V),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
      ),
    );
  }
}
class EPHeaderWidget extends EPWidget{

  EPWidgetType type=EPWidgetType.header;

  List<EPWidget> left=new List<EPWidget>();
  List<EPWidget> right=new List<EPWidget>();

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
    var ret=List<EPWidget>();

    var l=List<dynamic>.from(json);
    for (var i=0; i<l.length; i++){
      var fila=l[i];

      var type=fila['type'];
      var id=fila['id'];

      if (id!=null){
        EPWidget w=c.getWidgetByID(id);
        ret.add(w);
      } else if (type!=null){
        var xtype=c.getTypeForString(type);
        EPWidget w=c.getWidgetByType(xtype);

        ret.add(w);
      }
    }
    return ret;
  }


  Widget generateWidget(BuildContext context, ModelCard card, {bool isLeft, double maxWidth}) {
    setUpTheme(context);

    var MARGIN_H=16.0;

    var l=thisSide(context, card, this.left, true);
    var r=thisSide(context, card, this.right, false);

    var content=<Widget>[l, SizedBox(width: MARGIN_H), r];

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
  Widget thisSide(BuildContext context, ModelCard card, List<EPWidget> list, bool isLeft){
    var ret=List<Widget>();
    for (var i=0; i<list.length; i++){
      var fila=list[i];
      Widget w;

      if (fila.parent==null)
        fila.parent=this.parent;

      if (fila.type==EPWidgetType.images) {
        w = poster(context, card, isLeft);
      } else {
        w=fila.generateWidget(context, card, isLeft:!isLeft);
      }
      if (w!=null){
        ret.add(w);
        if (i<list.length-1) ret.add(SizedBox(height: MARGIN_V));
      }
    }
    if (ret.length==1)
      return ret[0];
    else {
      return Expanded(
        flex:1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ret
        )
      );
    }
  }
  Widget poster(BuildContext context, ModelCard card, bool isLeft){
    var width = POSTER_WIDTH;
    var height= POSTER_HEIGHT;

    EPImage field=this.parent.firstImageOfType(ImageType.poster);
    String url=card.get(field.field);

    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
    var domImage=Image.network(url, fit: doesNotWantsBox?BoxFit.contain:BoxFit.cover, height: height, );

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