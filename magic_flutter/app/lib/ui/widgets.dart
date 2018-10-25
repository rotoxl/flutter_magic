import 'dart:ui';

import 'dart:math';
import 'package:app/models/end_point.dart';
import 'package:app/ui/card_details.dart';
import 'package:app/ui/image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app/models/model_card.dart';
import 'package:app/app_data.dart';

enum EPWidgetType{
  name,

  images,
  tags,
  text,
  stats,
  fields,
  timeline,
  related,

  hero,
  header,
  separator
}
enum ImageType{
  poster, hero, thumbnail, image
}
enum NameType{
  left, right, name,

  linkToSameEndPoint, linkToOtherEndPoint,
}

abstract class EPWidget{
  final POSTER_RATIO = 0.7;
  final POSTER_HEIGHT= 200.0;
  final POSTER_WIDTH =140.0;

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
      else if (type=='related')
        return EPRelatedWidget.fromJson(json);
    }
    else if (key=='name'){
      return EPNameWidget.fromJson(json);
    }
    else
      return EPTextWidget.fromJson(json);
  }

  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth});
  String beautifulNumber(value){
    if (value==null) return null;

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

  Widget _imgPlaceholder(){
    return new Center(child:Container(height:40.0, width:40.0, child:CircularProgressIndicator()));
  }
  Widget _imgErrorPlaceholder({double width, double height}){
    return new Container(color:Colors.black26, width: width??80.0, height:height??80.0,);
  }
  static bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}

abstract class EPSubItem{
  String id, label;
  String left, right, field;
  String style, effect;
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
  String effect;

  EPTextWidget();

  factory EPTextWidget.fromJson(Map<String, dynamic> json) {
    var c=EPTextWidget();

    if (json['field']!=null)    c.field=json['field'];
    if (json['title']!=null)    c.title=json['title'];
    if (json['subtitle']!=null) c.subtitle=json['subtitle'];

    if (json['label']!=null)    c.label=json['label'];
    if (json['img']!=null)      c.img=json['img'];
    if (json['style']!=null)    c.style=json['style'];
    if (json['effect']!=null)    c.effect=json['effect'];

    if (json['fields']!=null){
      for (var i=0; i<json['fields'].length; i++){
        var fila=json['fields'][i];

        EPLabelText l=new EPLabelText();
        l.field=fila['field'];

        if (fila['id']!=null)
          l.id=fila['id'];

        if (fila['style']!=null)
          l.style=json['style'];
        if (fila['effect']!=null)
          l.effect=json['effect'];

        l.type=NameType.name;
        c.fields.add(l);
      }
    }

    return c;
  }
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
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
      var style=this.textTheme.body1;

      if (this.style=='title')
        style=this.textTheme.title;
      else if (this.style=='subtitle')
        style=this.textTheme.subtitle;
      else if (this.style=='headline')
        style=this.textTheme.headline;
      else if (this.style=='caption')
        style=this.textTheme.caption;
      else if (this.style=='display1')
        style=this.textTheme.display1;

      if (this.effect=='textShadow'){
        textContent.add(
            new ClipRect(
              child: new Stack(
                children: [
                  new Positioned(top: 1.0, left: 1.0, child: new Text(t, style: style.copyWith(color: Colors.black), textAlign: align) ),
                  new Text(t, style: style.copyWith(color: Colors.white), textScaleFactor:1.01, textAlign: align)
                ],
              ),
            )
        );
      }
      else {
        int maxLines=5;
        var moreStyle= textTheme.body1.copyWith(fontSize: 16.0, color: theme.accentColor);
        textContent.addAll([
          Text(t, style:this.textTheme.body1, textAlign: align, maxLines: maxLines),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('more', style: moreStyle),
              Icon(Icons.keyboard_arrow_down, size: 18.0, color: theme.accentColor,),
            ],
          )
        ]
        );

      }
    }

    wContent.add(
        Expanded(flex:2, child:Column(children: textContent, crossAxisAlignment: CrossAxisAlignment.start,))
    );

    if (this.img!=null){
      String url=card.get(this.img);

      if (url!=null){
        var height = POSTER_RATIO * POSTER_WIDTH;

        var img=CachedNetworkImage(imageUrl: this.parent.proxiedImage(url), placeholder:_imgPlaceholder(), errorWidget:_imgErrorPlaceholder(), fit: BoxFit.fitHeight, width: POSTER_WIDTH, height: height,);
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
    }

    return Container(
        padding:EdgeInsets.symmetric(horizontal:MARGIN_H, vertical:MARGIN_V),
        child:Row(children: wContent)
    );
  }
}

class EPFieldsWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.fields;

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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}){
    setUpTheme(context);

    var sec = <Widget>[];

    if (this.label!=null)
      sec.add( this.containerLabel(this.label) );

    var nonNullFieldsCount=0;
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

        if (value==null) {
          continue;
        }

        try{
          sec.add(
              new ListTile(
                  contentPadding: EdgeInsets.only(left:0.0, right:0.0),
                  title:Text(value),
                  subtitle: Text(field.label),
                  trailing: Icon(Icons.edit_attributes, color: theme.primaryColor)
              )
          );
          nonNullFieldsCount++;
        } catch(e, s){
        }
      }

    }

    if (nonNullFieldsCount==0)
      return null;

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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}){
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

    if (isLeft==null) isLeft=true;

    var lvw=ListView.builder(
      itemCount: ret.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(top: 0.0, left: 0.0),
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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}){
    setUpTheme(context);

    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.accentColor,);
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

  EPNameWidget();
  factory EPNameWidget .fromJson(Map<String, dynamic> json) {
    var c=new EPNameWidget();

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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
    setUpTheme(context);

    String texto;
    if (this.fields.length>0){
      texto=card.get(this.fields[0].field) ;
    }

    if (isLeft==null) isLeft=true;

    var t=Theme.of(context);
    var align=isLeft? TextAlign.start: TextAlign.right;
    if (this.type==EPWidgetType.name){
      return Text(texto, style: t.textTheme.title, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign:TextAlign.left,);
    } else {
      return Text(texto, style: this.textTheme.display1, textAlign:align,);
    }

  }

  String firstName() {
    return _getNtht(0).field;
  }
  secondName() {
    return _getNtht(1).field;
  }
  EPLabelText _getNtht(int index){
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

      if (count==index && (img.type==s || s==ImageType.image)) {
        return img;
      }
      if (img.type==s){
        count++;
      }
    }
  }

  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}){
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
    }
    return _buildPhotoScrollerList(context, ret);
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
        child: CachedNetworkImage(imageUrl: this.parent.proxiedImage(url), placeholder: _imgPlaceholder(), errorWidget:_imgErrorPlaceholder(), height: POSTER_HEIGHT, fit: BoxFit.scaleDown,),
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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
    return null;
  }
  factory EPHeroWidget.fromJson(Map<String, dynamic> json) {
    var c=EPHeroWidget();
    return c;
  }
}
class EPTimelineWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.timeline;

  String transform, sort;
  List<String>sort_strip=new List<String>();

  EPTimelineWidget();
  @override
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
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
          newdata[i]['side']= (j==0?'left':'right');
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

        if (EPWidget.isNumeric(vala) && EPWidget.isNumeric(valb)){
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
}
class EPSeparatorWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.separator;

  @override
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
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
    if (type=='separator'){
    ret.add(EPSeparatorWidget());
    }
    else {
    var xtype=c.getTypeForString(type);
    EPWidget w=c.getWidgetByType(xtype);
    ret.add(w);
    }
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
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
    setUpTheme(context);

    var MARGIN_H=16.0;

    var l=thisSide(context, card, this.left, true);

    var isLeft=false;
    if (this.parent.typeOfDetail==TypeOfDetail.details)
      isLeft=true;

    var r=thisSide(context, card, this.right, isLeft);

    var content=<Widget>[l, SizedBox(width: MARGIN_H), r];
    return _wrapRow(content);
  }
  Widget _wrapRow(List<Widget> content){
    return Stack(
        alignment: AlignmentDirectional.centerStart,
        children:[
          Padding(padding: EdgeInsets.only(bottom: POSTER_HEIGHT+20.0)),
          Positioned(
              left:MARGIN_H, right:MARGIN_H, bottom:MARGIN_V,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    if (isLeft==null)isLeft=true;

    if (ret.length==1)
      return ret[0];
    else {
      return Expanded(
          flex:1,
          child: Column(
              crossAxisAlignment: isLeft? CrossAxisAlignment.start: CrossAxisAlignment.end,
              children: ret
          )
      );
    }
  }
  Widget poster(BuildContext context, String url, bool isLeft){
    var width = POSTER_WIDTH;
    var height= POSTER_HEIGHT;

    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
    var domImage=CachedNetworkImage(imageUrl:this.parent.proxiedImage(url), placeholder: _imgPlaceholder(), errorWidget:_imgErrorPlaceholder(width:width, height:height), fit: doesNotWantsBox?BoxFit.contain:BoxFit.cover, width: width, height: height);

    return GestureDetector(
      child:doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
      onTap: () {
        navigateImagePage(url, context);
      },
    );
  }
}

class EPRelatedWidget extends EPWidget{
  EPWidgetType type=EPWidgetType.related;

  var IMG_WIDTH=80.0;
  String shape;

  List<ModelCard> relatedCards;
  EPRelatedWidget();
  @override
  Widget generateWidget(BuildContext context, ModelCard card, {DetailPageState detailPage, bool isLeft, double maxWidth}) {
    setUpTheme(context);

    var ret = <EPRelatedItem>[];
    EndPoint ep = appData.getCurrEndPoint();

    List<Widget> children = new List<Widget>();
    
    for (var i = 0; i < this.fields.length; i++) {
      EPRelatedItem f = this.fields[i];

      AppData.debugPrint(EndPoint.debug, 'EPRelatedItem', f);

      if (f.type == NameType.linkToSameEndPoint) {
        var values = card.get(f.field);

        if (values == null) {}
        else {
          if (values.runtimeType.toString() == 'String') {
            values = [values];
          }
          for (var j = 0; j < values.length; j++) {
            var value = values[j];

            ModelCard remote = ep.findCardById(value);

            String name = remote.get(ep.firstName());
            String url = remote.get(ep
                .firstImageOfType(ImageType.thumbnail)
                .field).toString();

            EPRelatedItem el = EPRelatedItem();
            el.url = url;
            el.text = name;
            el.id = value;

            ret.add(el);
          }
        }
      } else if (f.type == NameType.linkToOtherEndPoint) {
        var xid='${f.endPointTitle}*${this.id}';

        EndPoint related = appData.getEndPoint(f.endPointTitle);

        if (detailPage.relatedCards[xid]==null){
          //we'll fill the required parameter values
          Map<String, String> values = Map<String, String>();
          f.endPointParameter.forEach((String key, dynamic value) {
            dynamic v = card.get(value.toString());
            values[key] = v;
          });

          AppData.debugPrint(true, "parameters", values);
          related.fetchData(parameters: values).then((List<ModelCard> cards) {
            related.cards = cards;

            detailPage.setState((){
              detailPage.relatedCards[xid]=cards;
            });
          });
          
          return containerWithLabel(<Widget>[
            this._imgPlaceholder()
          ]);

        } else {
          List<ModelCard> list=detailPage.relatedCards[xid];
          related.cards=list;

          for (var i = 0; i < list.length; i++) {
            ModelCard c = list[i];

            EPRelatedItem el = EPRelatedItem();
            el.type=NameType.linkToOtherEndPoint;
            el.endPointTitle=related.endpointTitle;

            el.url = c.get(related
                .firstImageForListing()
                .field);
            el.text = c.get(related.firstName());
            el.id = c.get(related.id);
            
            ret.add(el);
          }
        }
      }
    }
    if (ret.length==0) return Container();
    
    children.add(_buildPhotoScrollerList(context, ret));
    return containerWithLabel(children);
  }
  Widget containerWithLabel(List<Widget>children){
    List<Widget> newChildren=new List<Widget>();

    if (this.label != null) {
      newChildren.addAll([
        Container(child: this.containerLabel(this.label),
            padding: EdgeInsets.only(left: MARGIN_H, bottom: MARGIN_V)),
        SizedBox(height: 8.0),
      ]);
    }
    newChildren.addAll(children);

    return Container(
        padding: EdgeInsets.symmetric(vertical: MARGIN_V),
        child: Column(children: children,
          crossAxisAlignment: CrossAxisAlignment.start,)
    );
  }
  Widget _buildPhotoScrollerList(BuildContext context, List<EPRelatedItem> ret){
    return SizedBox.fromSize(
        size: Size.fromHeight(IMG_WIDTH),
        child: ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(top: 0, left: MARGIN_H),
          itemBuilder: (buildContext, index) => _buildPhotoScrollerItem(context, ret[index]),
        )
    );
  }
  Widget _buildPhotoScrollerItem(BuildContext context, EPRelatedItem fila){
    String url=fila.url;

    Widget it=CachedNetworkImage(imageUrl: this.parent.proxiedImage(url), placeholder: _imgPlaceholder(), errorWidget:_imgErrorPlaceholder(), width: IMG_WIDTH, height: IMG_WIDTH, fit: BoxFit.fill,);
    if (this.shape=='circle'){
      it=ClipOval(child:it);
    }

    var el=Padding(padding: new EdgeInsets.only(right: MARGIN_H, top:0), child:it);

    return GestureDetector(
      child:el,
      onTap: () {
        EndPoint ep;

        if (fila.type==NameType.linkToOtherEndPoint){
          ep=appData.getEndPoint(fila.endPointTitle);
        } else {
          ep=appData.getCurrEndPoint();
        }

        var card= ep.findCardById(fila.id);
        Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context){
              return new DetailPage(card, ep: ep,);
            }
        ));
      },
    );
  }
  factory EPRelatedWidget.fromJson(Map<String, dynamic> json) {
    var c=EPRelatedWidget();

    var list=List<dynamic>.from(json['fields']);
    for (var i=0; i<list.length; i++){
      var fila=list[i];

      EPRelatedItem l=new EPRelatedItem();

      if (fila['linkType']!=null){
        if (fila['linkType']=='linkToSameEndPoint'){
          l.type=NameType.linkToSameEndPoint;
          l.field=fila['field'];

        } else if (fila['linkType']=='linkToOtherEndPoint'){
          l.type=NameType.linkToOtherEndPoint;

          l.endPointTitle=fila['endPointTitle'];
          l.endPointParameter=Map<String, dynamic>.from(fila['endPointParameter']);
        }
      }
      else
      l.type=NameType.linkToSameEndPoint;

      c.fields.add(l);
    }
    if (json['shape']!=null) c.shape=json['shape'];
    if (json['label']!=null) c.label=json['label'];

    return c;
  }
}
class EPRelatedItem extends EPSubItem{
  String url, id, text, extraText;
  NameType type;

  String endPointTitle;
  Map<String, dynamic> endPointParameter=new Map<String, dynamic>();
  String field;
}