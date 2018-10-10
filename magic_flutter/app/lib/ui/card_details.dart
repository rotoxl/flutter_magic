import 'dart:async';
import 'dart:math';

import 'package:app/app_data.dart';
import 'package:flutter/material.dart';

import 'package:app/models/end_point.dart';
import 'package:app/models/model_card.dart';
import 'package:app/ui/image_page.dart';

import 'package:app/ui/widgets.dart';

class DetailPage extends StatefulWidget {
  final ModelCard _card;
  ModelCard _cardToCompare;

  DetailPage(this._card, {Key key}) : super(key: key);
  DetailPage.compare(this._card, this._cardToCompare, {Key key}) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState(this._card, this._cardToCompare);
}

class _DetailPageState extends State<DetailPage> {
  EndPoint ep;
  final ModelCard _card;
  final ModelCard _cardToCompare;

  final HERO_HEIGHT = 156.0;
  final POSTER_RATIO = 0.7;
  final POSTER_HEIGHT= 180.0;

  final MARGIN_H=16.0;

  ThemeData theme;
  TextTheme textTheme;
  TextStyle styleOverline, styleBody;


  _DetailPageState(this._card, this._cardToCompare);

  Future<Null> editAttributes() async {
  }

  @override
  Widget build(BuildContext context) {
    this.theme= Theme.of(context);
    this.textTheme= Theme.of(context).textTheme;
    this.styleOverline=this.textTheme.button.copyWith(fontSize: 10.0);
    this.styleBody=this.textTheme.body1;

    ep=getEndPoint();

    appData.logEvent('detail_show', {'ep':ep.endpointTitle, 'typeOfDetail':ep.typeOfDetail.toString(), 'card':this._card.id, 'cardToCompare':this._cardToCompare!=null?this._cardToCompare.id:null} );

    List<Widget>allWidgets;
    if (ep.typeOfDetail==TypeOfDetail.details){
      allWidgets=detailPage(context);

//    } else if (ep.typeOfDetail==TypeOfDetail.productCompare){
//      allWidgets=comparePage();

//    } else if (ep.typeOfDetail==TypeOfDetail.hero){
//      return heroPage();
//    } else if (ep.typeOfDetail==TypeOfDetail.match){
//      allWidgets=matchPage();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          SliverList(
            delegate:new SliverChildListDelegate(allWidgets),
          ),
        ],
      ),
    );
  }

  List<Widget> detailPage(BuildContext context){
    List<Widget>ret=new List<Widget>();

    for (var i=0; i<ep.widgetsOrder.length; i++){
      var w=ep.widgetsOrder[i];

      Widget content=w.generateWidget(context, _card);
      if (content!=null)
        ret.add( content );

    }
    ret.add(SizedBox(height:16.0));
//    allWidgets.addAll([posterAndTitleBlock(), separator(),]);
//
//    var d=descWidget();
//    if (d!=null) allWidgets.addAll([d, separator()]);
//
//    var s=secondaryFieldsWidget(_card);
//    if (s!=null) allWidgets.addAll([s, separator()]);
//
//    var p=photoScroller();
//    if (p!=null) allWidgets.addAll([p, separator()]);

    return ret;
  }
//  List<Widget> comparePage(){
//    List<Widget>allWidgets=new List<Widget>();
//    allWidgets.addAll([
//      new Container(color:this.theme.canvasColor, child:sidebyside( posterWName(_card, true), posterWName(_cardToCompare, false) ) ),
//      separator(),
//    ]);
//
//    allWidgets.addAll([
//      compareFields(),
//      separator(),
//    ]);
//    return allWidgets;
//  }
//  Widget heroPage(){
//    var ep=getEndPoint();
//    var src=_card.get(ep.firstImageOfType(ImageType.hero));
//
//    var subheadStyle=Theme.of(context).textTheme.subhead.copyWith(color: Colors.white);
//    var headStyle=Theme.of(context).textTheme.title.copyWith(color: Colors.white);
//
//    var name=_card.get(ep.firstName());
//    var text=_card.get(ep.text);
//
//    var ret=new Container(
//      color: ep.epTheme.canvasColor,
//      child:new Container(
//        decoration: new BoxDecoration(
//          image: new DecorationImage(image: new Image.network(src ).image, fit: BoxFit.fitHeight),
//        ),
//        child: new Stack(children: <Widget>[
//          new Positioned(
//            bottom: 40.0, left: MARGIN_H, right: MARGIN_H,
//            child: Column(
//              children: <Widget>[
//                name==null?Container(): new Text(_card.get(ep.firstName()), style:headStyle, textAlign: TextAlign.center,),
//                new Container(height: 10.0,),
//                text==null?Container(): new Text(text, style:subheadStyle, textAlign: TextAlign.center)
//              ],),),
//        ],)
//      )
//    );
//
//    return new GestureDetector(child: ret, onTap: () => Navigator.pop(context, 'Nope!'),);
//  }
//  List<Widget> matchPage(){
//    var tt=Theme.of(context).textTheme;
//
//    EndPoint ep=this.getEndPoint();
//
//    List<Widget>allWidgets=new List<Widget>();
//    allWidgets.addAll([
//      new Container(height:22.0, child:new Text(_card.get(ep.section), style:tt.caption, textAlign: TextAlign.start), margin:EdgeInsets.only(top:20.0, left:MARGIN_H)),
//      new Container(color:this.theme.canvasColor, child:sidebyside(
//          teamPoster(_card.get(ep.firstName()), _card.get('{home_team/goals}'), _card.get(ep.firstImage()), true),
//          teamPoster(_card.get(ep.secondName()),_card.get('{away_team/goals}'), _card.get(ep.secondImage()), false),
//          bottom:130.0,
//        )
//      ),
//    ]);
//
//    //TODO Officials
//    // allWidgets.addAll([
//    //    separator(),
//    //      sectionLabel('Officials'),
//    //      teamTags(),
//    //
//    //    ]);
//
//    if (ep.venue!=null){
//      allWidgets.addAll([
//        separator(),
//        sectionLabel('Venue'),
//        textAndImage(_card.get(ep.venue["title"]), _card.get(ep.venue["subtitle"]), ep.venue["img"]),
//      ]);
//    }
//
//    if (ep.events!=null){
//      allWidgets.addAll([
//        separator(),
//        sectionLabel('Events'),
//      ]);
//
//      //hay que meter el campo origin:left/right para distinguirlas
//      List<dynamic>timelinedata=[];
//      for (var j=0; j<ep.events['list'].length; j++){
//        var key=ep.events['list'][j];
//        List<dynamic>newdata=_card.get(key);
//
//        for (var i=0; i<newdata.length; i++){
//          if (ep.events['kind']=='home/away'){
//            newdata[i]['side']= (j==0?'left':'right');
//          }
//        }
//        timelinedata.addAll(newdata);
//      }
//      if (ep.events.containsKey('sort')){
//        var whichField=ep.events['sort'];
//
//        timelinedata.sort((a,b){
//          var vala=a[whichField].toString();
//          var valb=b[whichField].toString();
//
//          if (ep.events['sort_strip']!=null){
//            List<String> l=ep.events['sort_strip'];
//            for (var i=0; i<l.length; i++){
//              vala=vala.replaceAll(l[i], '');
//              valb=valb.replaceAll(l[i], '');
//            }
//          }
//
//          if (isNumeric(vala) && isNumeric(valb)){
//            var numa=int.parse(vala);
//            var numb=int.parse(valb);
//
//            return numa.compareTo(numb);
//          } else {
//            return vala.compareTo(valb);
//          }
//        });
//      }
//
//      allWidgets.addAll(timeLine(timelinedata));
//    }
//
//    if (ep.match_fields!=null){
//      allWidgets.addAll([
//        separator(),
//        sectionLabel('Stats'),
//        teamFields(),
//      ]);
//    }
//
//    return allWidgets;
//  }
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
//  List<Widget> timeLine(data){
//    var rowHeight=60.0;
//    var screenWidth=MediaQuery.of(context).size.width;
//
//    var centerColWidth=40.0;
//    var colWidth=(screenWidth-centerColWidth)/2;
//
//    var l=<Widget>[];
//
//    for (var i=0;i<data.length; i++){
//      var fila=data[i];
//
//      Container leftCol=new Container(width:colWidth); Container rightCol=new Container(width:colWidth);
//      var centerCol; var colItems;
//
//      colItems=[
//        Text(fila['time'], style:textTheme.caption),
//        Text(fila['type_of_event'], style:textTheme.caption ),
//        Expanded(child:Text(fila['player'], style:textTheme.subhead, overflow: TextOverflow.fade, maxLines: 1, softWrap: false,)),
//      ];
//
//      if (fila['side']=='left') {//isIzq
//        leftCol=new Container(width:colWidth, child:new Column(children: colItems, crossAxisAlignment: CrossAxisAlignment.end),);
//      } else {
//        rightCol=new Container(width:colWidth, child:new Column(children: colItems, crossAxisAlignment: CrossAxisAlignment.start));
//      }
//
//      double bulletTop=rowHeight/4;
//      double lineStart=0.0, lineEnd=rowHeight;
//      if (i==0){
//        lineStart=bulletTop;
//        lineEnd=rowHeight-lineStart;
//      }
//      else if (i==data.length-1){
//        lineStart=0.0;
//        lineEnd=bulletTop;
//      }
//
//      centerCol=new Container(height: rowHeight, width:centerColWidth, child: new Stack(children: <Widget>[
//            new Positioned(
//              top: lineStart, height: lineEnd, left: 25.0,
//              child: new Container(height: 20.0, width: 1.0, color: Colors.grey),
//            ),
//            new Positioned(
//              top: bulletTop-8.0, left: 16.0,
//              child: new Container(
//                margin: new EdgeInsets.all(5.0),
//                height: 10.0, width: 10.0,
//                decoration: new BoxDecoration(shape: BoxShape.circle,color: theme.accentColor),
//                ),
//              )
//          ])
//        );
//
//      l.add(new Container(height:rowHeight, width:screenWidth, child:new Row(children: <Widget>[leftCol, centerCol, rightCol] )));
//
//    }
//  return l;
//  }
//
//  Widget sectionLabel(String label){
//    return new Container(margin:EdgeInsets.only(left:MARGIN_H, bottom:8.0, top:8.0, ), child: Text(label, style: textTheme.subhead));
//  }
  Widget textAndImage(String title, String subtitle, String url){
    var POSTER_WIDTH =100.0;
    var height = POSTER_RATIO * POSTER_WIDTH;

    var domImage=new Image.network(url, fit: BoxFit.fitHeight, width: POSTER_WIDTH, height: height,);
    var boxedImage=Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage);

    var gd=GestureDetector(
      child:boxedImage,
      onTap: () {
        navigateImagePage(url, context);
      },
    );

    return new Container(margin:EdgeInsets.only(left:MARGIN_H, right:MARGIN_H, bottom:8.0, top:2.0), child: Row(children: <Widget>[
      new Expanded(flex:2, child:Column(children: <Widget>[
          Text(title, style:styleBody, ),
          Text(subtitle, style:textTheme.body2.copyWith(color: Colors.grey), ),
          ], crossAxisAlignment: CrossAxisAlignment.start,)
      ),
      new Expanded(flex:1, child:gd),
      ])
    );
  }
//  Widget teamFields(){
//    var lista=getEndPoint().match_fields;
//
//    List<Widget>sec = new List<Widget>();
//
//    for (int i = 0; i <lista.length; i++) {
//      var fila=lista[i];
//
//      var attText = fila["label"];
//      if (attText=='separator'){
//        sec.add(SizedBox(height:18.0));
//        continue;
//      }
//      var attrLeft = fila["left"];
//      var attrRight = fila["right"];
//
//      var value1 = beautifulNumber( valueForField(_card.get(attrLeft)).toString() );
//      var value2 = beautifulNumber( valueForField(_card.get(attrRight)).toString() );
//
//      sec.add( _valueLabelValue(value1, attText, value2));
//    }
//    return new Container(child: Column(children: sec,),);
//  }

//  Widget teamTags(){
//    var ret=<String>[];
//
//    if (getEndPoint().tags==null)
//      return Container();
//
//    var chipsAttr=["officials"]; //getEndPoint().tags;
//
//    for (var i=0; i<chipsAttr.length; i++){
//      var fieldName=chipsAttr[i];
//      print (fieldName);
//      var values=_card.get(fieldName);
//
//      if (values==null || values==''){
//        //pass
//      }
//      else if (values.runtimeType.toString()=='String'){
//        if (values.indexOf(',')>-1){
//          var temp=values.split(',');
//          for (var j=0; j<temp.length; j++){
//            ret.add( temp[j].toString().trim() );
//          }
//        }
//        else
//          ret.add(values);
//      }
//      else {
//        for (var j=0; j<values.length; j++) {
//          var value=values[j];
//          ret.add(value);
//        }
//      }
//    }
//
//    return SizedBox.fromSize(
//        size: const Size.fromHeight(40.0),
//        child: ListView.builder(
//          itemCount: ret.length,
//          scrollDirection: Axis.horizontal,
//          padding: EdgeInsets.only(top: 0.0, left: MARGIN_H),
//          itemBuilder: (BuildContext, index) => _buildChip(ret[index]),
//        )
//    );
//  }
  double getHeightForImage(double width){
    return width*POSTER_RATIO;
  }
//  Widget teamPoster(String name, String result, String url, isLeft){
//    var POSTER_WIDTH =100.0;
//
//    if (url==null || url=='') url=ModelCard.getImgPlaceholder();
//
//    var domImage=new Image.network(url, fit: BoxFit.fill, width: POSTER_WIDTH, height: getHeightForImage(POSTER_WIDTH),);
//
//    return new Column(
//        crossAxisAlignment: isLeft?CrossAxisAlignment.start:CrossAxisAlignment.end,
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: [
//          Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
//          SizedBox(height: 8.0),
//          Text(name, style: styleBody),
//          Text(result, style: textTheme.title),
//        ]
//    );
//  }

  valueForField(value) {
    if (value == null)
      return null;
    else if (value.runtimeType.toString() == 'List<dynamic>')
      return value[0];
    else
      return value;
  }
  Widget appBar() {
    var ep=getEndPoint();

    var h=ep.getWidgetByType(EPWidgetType.hero);

    var expanded_height; var domImage;

    if (h!=null){
      expanded_height=HERO_HEIGHT;

      var src=_card.get(ep.firstImageOfType(ImageType.hero).field );
      if (src==null || src=='') src=ModelCard.getImgPlaceholder();

      domImage=Image.network(src, fit: BoxFit.cover, height: expanded_height, color: Colors.white.withOpacity(0.15),colorBlendMode: BlendMode.lighten);
    }  else {
      expanded_height=16.0;
      domImage=Container();
    }

    return SliverAppBar(
      pinned: false,
      leading: IconButton(
          icon: Icon(Icons.close),
          color:Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pop(context, 'Nope!');
          }),
      expandedHeight: expanded_height,
      elevation: 1.0,
      floating: false,
      // floating: true, snap: true,
      flexibleSpace: new FlexibleSpaceBar(background: domImage),
//      actions: <Widget>[
//        new IconButton(
//            icon: const Icon(Icons.edit),
//            tooltip: 'Edit',
//            onPressed: () {
//              this.editAttributes();
//            }),
//      ],
    );
  }

//  Widget compareFields() {
//    List<Widget>sec = new List<Widget>();
//
//    for (int i = 0; i < getEndPoint().fields.length; i++) {
//      var attr = getEndPoint().fields[i];
//      var att_text = beautifulAttr(attr);
//
//      var value1 = beautifulNumber( valueForField(_card.get(attr)).toString() );
//      var value2 = beautifulNumber( valueForField(_cardToCompare.get(attr)).toString() );
//
//      sec.add(
//        _valueLabelValue(value1, att_text, value2)
//      );
//    }
//    return new Container(child: Column(children: sec,),);
//  }
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

  EndPoint getEndPoint(){
    return appData.getCurrEndPoint();
  }
  navigateImagePage(String url, BuildContext context){
    Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new ImagePage(url:url),
    ));
  }

//  Widget posterAndTitleBlock() {
//    var ep=getEndPoint();
//
//    var src=_card.get(ep.firstImage());
//    var name = _card.get(ep.firstName());
//
//    return Stack(children: [
//      Padding(padding: const EdgeInsets.only(bottom: 200.0)),
//
//      Positioned(
//        bottom: 0.0,
//        left: MARGIN_H,
//        right: MARGIN_H,
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.end,
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: [
//            _titleLeftBlock(src, altImage:ModelCard.getImgPlaceholder()),
//            SizedBox(width: MARGIN_H),
//            _titleRightBlock(name),
//          ],
//        ),
//      ),
//
//    ]);
//  }
//  Widget _titleLeftBlock(String url, {String altImage}) {
//    var width = POSTER_RATIO * POSTER_HEIGHT;
//
//    if (url==null || url=='') url=altImage;
//
//    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
//    var domImage=Image.network(url, fit: doesNotWantsBox?BoxFit.contain:BoxFit.cover, width: width, height: POSTER_HEIGHT,);
//
//    return GestureDetector(
//        child:doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
//        onTap: () {
//          if (url!=altImage)
//            navigateImagePage(url, context);
//        },
//    );
//  }
//  Widget _titleRightBlock(name) {
//    var textTheme = Theme.of(context).textTheme;
//
//    return Expanded(
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Text(name, style: textTheme.headline, maxLines: 3, overflow: TextOverflow.ellipsis,),
//
//            SizedBox(height: 8.0),
//            _stats(),
//
//            SizedBox(height: 8.0),
//            _chips(),
//          ],
//        )
//    );
//  }

//  Widget sidebyside(Widget left, Widget right, {double bottom=220.0}){
//    return Stack(children: [
//      Padding(padding: EdgeInsets.only(bottom: bottom)),
//      Positioned(
//        bottom: 0.0, left: MARGIN_H, right: MARGIN_H,
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: [
//            left,
//            Expanded(child:Container()),
//            right,
//          ],
//        ),
//      )
//    ]);
//  }
//  Widget posterWName(ModelCard newcard, bool isLeft){
//    var ep=getEndPoint();
//
//    var url=newcard.get(ep.firstImage());
//    var name = newcard.get(ep.firstName());
//
//    var themeSoft = textTheme.headline;
//
//    var width = POSTER_RATIO * POSTER_HEIGHT;
//
//    if (url==null || url=='') url=ModelCard.getImgPlaceholder();
//
//    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
//    var domImage=new Image.network(url, fit: doesNotWantsBox?BoxFit.scaleDown: BoxFit.cover, width: width, height: POSTER_HEIGHT,);
//
//    return new Column(
//      crossAxisAlignment: isLeft?CrossAxisAlignment.start:CrossAxisAlignment.end,
//      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//      children: [
//        doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
//        SizedBox(height: 8.0),
//        Text(name, style: themeSoft, textAlign: TextAlign.center),
//     ]
//    );
//  }

//  Widget _stats(){
//    var ret=<Widget>[];
//
//    var listaAtr=getEndPoint().stats;
//
//    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.primaryColor,);
//    var themeSoft = textTheme.caption.copyWith(color: theme.textTheme.caption.decorationColor);
//
//    for (var i=0; i<listaAtr.length; i++){
//      if (i>0) ret.add( SizedBox(width: MARGIN_H) );
//
//      var att=listaAtr[i];
//      var att_text=beautifulAttr(att);
//
//      var value=beautifulNumber( _card.get(att) );
//
//      var numericRating = Column(
//        crossAxisAlignment: CrossAxisAlignment.center,
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: [
//          Text(value, style: themeBold, textAlign: TextAlign.center,),
//          SizedBox(height: 4.0),
//          Text(att_text, style: themeSoft,),
//        ],
//      );
//
//      ret.add(numericRating);
//    }
//
//    return SizedBox.fromSize(
//        size: const Size.fromHeight(50.0),
//        child: ListView.builder(
//          itemCount: ret.length,
//          scrollDirection: Axis.horizontal,
//          padding: const EdgeInsets.only(top: 0.0, left: 0.0),
//          itemBuilder: (BuildContext, index) => ret[index],
//        )
//    );//Row(crossAxisAlignment: CrossAxisAlignment.end, children: ret);
//  }
  beautifulAttr(att){
    var ret=att;

    do{
      var sep;
      if (ret.indexOf('/')>-1){
        sep='/';
      } else if (ret.indexOf('_')>-1){
        sep='_';
      }
      if (sep==null) return ret;

      var temp=ret.split(sep);
      ret=temp[temp.length-1].toString();
      ret=ret.replaceAll("{", "").replaceAll("}", "");
    } while (ret.indexOf('/')>-1 || ret.indexOf('_')>-1);

    return ret;
  }
//  beautifulNumber(value){
//    var orig=value;
//    try{
//      if (value.runtimeType.toString()=='int'){
//        //pass
//      }
//      else{
//        value=double.parse(value.toString());
//      }
//    } catch (e){
//      return value.toString();
//    }
//    String ret; String unit='';
//    if (value>1000000){
//      ret=(value/1000000).toString().substring(0,3);
//      unit="M";
//    }
//    else if (value>1000){
//      ret=(value/1000).toString().substring(0,3);
//      unit="K";
//    }
//    else if (value>100)
//      ret=value.round().toString().substring(0,3);
//    else{
//      var t=value.toString();
//      ret=t.substring(0, min(3, t.length) );
//    }
//
//    if (ret.endsWith('.0') ){
//      ret=ret.substring(0, ret.length-2);
//    } else if (ret.endsWith('.')){
//      ret=ret.substring(0, ret.length-1);
//    }
//
//    print (orig.toString() + ' --> '+ret+unit);
//    return ret+unit;
//
//  }

//  Widget _chips(){
//    var ret=<String>[];
//
//    if (getEndPoint().tags==null)
//      return Container();
//
//    var chipsAttr=getEndPoint().tags;
//
//    for (var i=0; i<chipsAttr.length; i++){
//      var fieldName=chipsAttr[i];
//      print (fieldName);
//      var values=_card.get(fieldName);
//
//      if (values==null || values==''){
//        //pass
//      }
//      else if (values.runtimeType.toString()=='String'){
//        if (values.indexOf(',')>-1){
//          var temp=values.split(',');
//          for (var j=0; j<temp.length; j++){
//            ret.add( temp[j].toString().trim() );
//          }
//        }
//        else
//          ret.add(values);
//      }
//      else {
//        for (var j=0; j<values.length; j++) {
//          var value=values[j];
//          ret.add(value);
//        }
//      }
//    }
//
//    return SizedBox.fromSize(
//        size: const Size.fromHeight(40.0),
//        child: ListView.builder(
//          itemCount: ret.length,
//          scrollDirection: Axis.horizontal,
//          padding: const EdgeInsets.only(top: 0.0, left: 0.0),
//          itemBuilder: (BuildContext, index) => _buildChip(ret[index]),
//        )
//    );
//  }
//  Widget _buildChip(String value) {
//    return Padding(
//        padding: const EdgeInsets.only(right: 8.0),
//        child: Chip(
//          label: Text(value),
//          labelStyle: textTheme.caption,
//          backgroundColor: Colors.black12,
//        ),
//      );
//  }
//
//  Widget separator() {
//    return Container(
//      padding: const EdgeInsets.symmetric(vertical: 8.0),
//      decoration: new BoxDecoration(
//          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
//      ),
//    );
//  }
//
//  Widget descWidget(){
//    var value=_card.get( getEndPoint().text );
//
//    if (value==null)
//      return null;
//
//    var body2Accent=this.textTheme.body2.copyWith(color: theme.primaryColor);
//
//    return Padding(
//        padding: EdgeInsets.only(top:16.0, left: MARGIN_H, right:MARGIN_H),
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Text('Desc', style: styleOverline),
//            SizedBox(height: 8.0),
//            Text(value, style:styleBody,),
//
//            Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              crossAxisAlignment: CrossAxisAlignment.end,
//              children: [
//                Text('more', style: body2Accent),
//                Icon(Icons.keyboard_arrow_down, size: 18.0, color: theme.primaryColor,),
//              ],
//            ),
//          ],
//        )
//    );
//  }

//  Widget secondaryFieldsWidget(ModelCard newcard) {
//    var sec = <Widget>[];
//
//    for (int i=0; i<getEndPoint().fields.length; i++) {
//      var attr=getEndPoint().fields[i];
//      var att_text=beautifulAttr(attr);
//
//      var value=newcard.get(attr);
//
//      if (value==null){
//        continue;
//      }
//      else if (value.runtimeType.toString()=='List<dynamic>')
//        value=value[0];
//
//      try{
//        sec.add(
//          new WidgetCategoryItem(
//            lines: <String>[value, att_text],
//          ),
//        );
//      } catch(e, s){
////        sec.add( new WidgetCategoryItem(
////          lines: <String>["Error", attr],
////        ),);
//      //pass
//      }
//    }
//
//    if (sec.length==0)
//      return null;
//    return new WidgetCategory(icon: Icons.edit_attributes, children: sec);
//  }

//  Widget photoScroller(){
//    var ret=<String>[];
//
//    var images=getEndPoint().images;
//
//    if (images==null || images.length<2)
//      return null;
//
//    for (var i=0; i<images.length; i++){
//      var fieldName=images[i];
//      var values=_card.get(fieldName);
//
//      if (values==null){
//        //pass
//      }
//      else if (values.runtimeType.toString()=='String'){
//        ret.add(values);
//      }
//      else {
//        for (var j=0; j<values.length; j++) {
//          var value=values[j];
//          ret.add(value);
//        }
//      }
//    }
//    return SizedBox.fromSize(
//        size: const Size.fromHeight(140.0),
//        child: ListView.builder(
//          itemCount: ret.length,
//          scrollDirection: Axis.horizontal,
//          padding: const EdgeInsets.only(top: 8.0, left: 20.0),
//          itemBuilder: (BuildContext, index) => _buildPhotoScrollerItem(ret[ret.length-1-index]),
//        )
//    );
//  }
//  _buildPhotoScrollerItem(url){
////    var height=180.0;
////    var width = POSTER_RATIO * height;
//
//    if (url=='') return null;
//
//    var el=Padding(
//      padding: new EdgeInsets.only(right: MARGIN_H),
//      child: ClipRRect(
//        borderRadius: BorderRadius.circular(4.0),
//        child: Image.network(url, width: 160.0, height: 120.0, fit: BoxFit.cover,),
//      ),
//    );
//
//    return GestureDetector(
//      child:el,
//      onTap: () {
//        navigateImagePage(url, context);
//      },
//    );
//  }


  void _showSnackbar(String text, BuildContext xcontext) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    Scaffold.of(xcontext).showSnackBar(snackBar);
  }

}
