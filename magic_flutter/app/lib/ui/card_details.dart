import 'dart:async';
import 'dart:math';

import 'package:app/app_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:app/models/end_point.dart';
import 'package:app/models/model_card.dart';

import 'package:app/ui/widgets.dart';

class DetailPage extends StatefulWidget {
  final ModelCard _card;
  ModelCard _cardToCompare;
  EndPoint ep;

  DetailPage(this._card, {Key key, EndPoint this.ep}){
    if (this.ep==null)
      this.ep=appData.getCurrEndPoint();
  }

  DetailPage.compare(this._card, this._cardToCompare, {Key key}) : super(key: key);

  @override
  DetailPageState createState() => new DetailPageState(this._card, this._cardToCompare, this.ep);
}

class DetailPageState extends State<DetailPage> {
  final ModelCard _card;
  final ModelCard _cardToCompare;

  final HERO_HEIGHT = 156.0;
  final MARGIN_H=16.0;

  ThemeData theme;
  TextTheme textTheme;
  TextStyle styleOverline, styleBody;

  Map<String, List<ModelCard>> relatedCards=Map<String, List<ModelCard>>();
  EndPoint ep;

  DetailPageState(this._card, this._cardToCompare, this.ep);
  
  Future<Null> editAttributes() async {
  }

  @override
  Widget build(BuildContext context) {
    this.theme= Theme.of(context);
    this.textTheme= Theme.of(context).textTheme;
    this.styleOverline=this.textTheme.button.copyWith(fontSize: 10.0);
    this.styleBody=this.textTheme.body1;

    appData.logEvent('detail_show', {
      'ep':ep.endpointTitle, 
      'typeOfDetail':ep.typeOfDetail.toString(), 
      'card':this._card.id, 
      'cardToCompare':this._cardToCompare!=null?this._cardToCompare.id:null
      } 
    );

    print ('----------------------');
    print (this._card.json);

    List<Widget>allWidgets;
    if (ep.typeOfDetail==TypeOfDetail.details){
      allWidgets=detailPage(context);
    } else if (ep.typeOfDetail==TypeOfDetail.match){
      allWidgets=matchPage();
    } else if (ep.typeOfDetail==TypeOfDetail.productCompare){
      allWidgets=comparePage();
    } else if (ep.typeOfDetail==TypeOfDetail.hero){
      allWidgets=heroPage();
    }

    if (ep.typeOfDetail==TypeOfDetail.hero){
      return Scaffold(
          body: Column(children:allWidgets)
      );
    }
    else {
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
  }

  List<Widget> detailPage(BuildContext context){
    List<Widget>ret=new List<Widget>();
    
    for (var i=0; i<ep.widgetsOrder.length; i++){
      EPWidget w=ep.widgetsOrder[i];

      w.parent=ep;
      Widget content=w.generateWidget(context, _card, detailPage:this);
      if (content!=null)
        ret.add( content );
    }
    ret.add(SizedBox(height:MARGIN_H));

    return ret;
  }
  List<Widget> matchPage(){
    List<Widget>ret=new List<Widget>();

    for (var i=0; i<ep.widgetsOrder.length; i++){
      var w=ep.widgetsOrder[i];

      // print ('widget ${w.id}, ${w.type.toString()}');
      Widget content=w.generateWidget(context, _card);
      if (content!=null)
        ret.add( content );
    }
    ret.add(SizedBox(height:MARGIN_H));

    return ret;
  }
  List<Widget> comparePage(){
    List<Widget>ret=new List<Widget>();

    for (var i=0; i<ep.widgetsOrder.length; i++){
      var w=ep.widgetsOrder[i];
      w.parent=ep;

      print ('widget ${w.id}, ${w.type.toString()}');
      Widget content=w.generateWidgetCompare(context, _card, _cardToCompare);
      if (content!=null)
        ret.add( content );
    }
    ret.add(SizedBox(height:MARGIN_H));

    return ret;
  }
  List<Widget> heroPage(){
    var size=MediaQuery.of(context).size;

    Widget image;
    List<Widget> text=new List<Widget>();
    String src;

    for (var i=0; i<ep.widgetsOrder.length; i++){
      EPWidget w=ep.widgetsOrder[i];
      w.parent=ep;
      print ('widget ${w.id}, ${w.type.toString()}');

      if (w.type==EPWidgetType.images || w.type==EPWidgetType.hero){
        src=_card.get(ep.firstImageOfType(ImageType.hero).field);
      }
      else {
        text.add( w.generateWidget(context, _card) );
        //text.add(SizedBox(height:8.0));
      }
    }

    var ret=new Container(
      height:size.height,
      width: size.width,
      color: ep.epTheme.theme.canvasColor,
      child:new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new CachedNetworkImageProvider(this.ep.proxiedImage(src)), fit: BoxFit.fitHeight,),
        ),
        child: new Stack(children: <Widget>[
          new Positioned(
            bottom: 10.0, left: MARGIN_H, right: MARGIN_H,
            child: Column(children:text)
          ),
        ],)
      )
    );

    return [
      GestureDetector(child: ret, onTap: () => Navigator.pop(context, 'Nope!'),)
    ];
  }

  Widget appBar() {
    var expanded_height; var domImage;

    if (ep.typeOfDetail==TypeOfDetail.hero){
    }
    else {
      var h=ep.getWidgetByType(EPWidgetType.hero);
      if (h!=null){
        expanded_height=HERO_HEIGHT;

        var src=_card.get(ep.firstImageOfType(ImageType.hero).field );
        if (src==null || src=='') src=ModelCard.getImgPlaceholder();

        domImage=Image.network( ep.proxiedImage(src), fit: BoxFit.cover, height: expanded_height, color: Colors.white.withOpacity(0.15),colorBlendMode: BlendMode.lighten);
      }  else {
        expanded_height=16.0;
        domImage=Container();
      }

      return SliverAppBar(
        pinned: false,
        leading: IconButton(
            icon: Icon(Icons.close, color:Theme.of(context).textTheme.title.color),
            color:Theme.of(context).accentColor,
            onPressed: () {
              Navigator.pop(context, 'Nope!');
            }),
        expandedHeight: expanded_height,
        elevation: 1.0,
        floating: false,
        // floating: true, snap: true,
        flexibleSpace: new FlexibleSpaceBar(background: domImage),
      );
    }


  }

  EndPoint getEndPoint(){
    return appData.getCurrEndPoint();
  }

  void _showSnackbar(String text, BuildContext xcontext) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    Scaffold.of(xcontext).showSnackBar(snackBar);
  }

}
