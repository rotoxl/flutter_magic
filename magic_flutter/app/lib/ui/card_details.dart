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
  final ModelCard _card;
  final ModelCard _cardToCompare;

  final appBarHeight = 156.0;
  final POSTER_RATIO = 0.7;
  final POSTER_HEIGHT= 180.0;

  ThemeData theme;
  TextTheme textTheme;

  _DetailPageState(this._card, this._cardToCompare);

  Future<Null> editAttributes() async {
  }

  @override
  Widget build(BuildContext context) {
    this.theme= Theme.of(context);
    this.textTheme= Theme.of(context).textTheme;

    var ep=getEndPoint();

    appData.logEvent('detail_show', {'ep':ep.endpointTitle, 'typeOfDetail':ep.typeOfDetail.toString(), 'card':this._card.id, 'cardToCompare':this._cardToCompare!=null?this._cardToCompare.id:null} );

    List<Widget>allWidgets;
    if (ep.typeOfDetail==TypeOfDetail.detailsPage){
      allWidgets=detailPage();

    } else if (ep.typeOfDetail==TypeOfDetail.productCompare){
      allWidgets=comparePage();

    } else if (ep.typeOfDetail==TypeOfDetail.heroPage){
      return heroPage();
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

  List<Widget> detailPage(){
    List<Widget>allWidgets=new List<Widget>();
    allWidgets.addAll([posterAndTitleBlock(), separator(),]);

    var d=descWidget();
    if (d!=null) allWidgets.addAll([d, separator()]);

    var s=secondaryFieldsWidget(_card);
    if (s!=null) allWidgets.addAll([s, separator()]);

    var p=photoScroller();
    if (p!=null) allWidgets.addAll([p, separator()]);

    return allWidgets;
  }
  List<Widget> comparePage(){
    List<Widget>allWidgets=new List<Widget>();
    allWidgets.addAll([
      new Container(color:this.theme.canvasColor, child:sidebyside( posterWName(_card, true), posterWName(_cardToCompare, false) ) ),
      separator(),
    ]);

    allWidgets.addAll([
      compareFields(),
      separator(),
    ]);
    return allWidgets;
  }
  Widget heroPage(){
    var ep=getEndPoint();
    var src=_card.get(ep.firstImage());

    var subheadStyle=Theme.of(context).textTheme.subhead.copyWith(color: Colors.white);
    var headStyle=Theme.of(context).textTheme.title.copyWith(color: Colors.white);

    var name=_card.get(ep.name);
    var text=_card.get(ep.text);

    var ret=new Container(
      color: ep.theme.canvasColor,
      child:new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new Image.network(src ).image, fit: BoxFit.fitHeight),
        ),
        child: new Stack(children: <Widget>[
          new Positioned(
            bottom: 40.0, left: 16.0, right: 16.0,
            child: Column(
              children: <Widget>[
                name==null?Container(): new Text(_card.get(ep.name), style:headStyle, textAlign: TextAlign.center,),
                new Container(height: 10.0,),
                text==null?Container(): new Text(text, style:subheadStyle, textAlign: TextAlign.center)
              ],),),
        ],)
      )
    );

    return new GestureDetector(child: ret, onTap: () => Navigator.pop(context, 'Nope!'),);
  }

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

    var src=_card.get(ep.secondImage() );
    if (src==null || src=='') src=_card.getImgPlaceholder();

    var height=appBarHeight;
    if (ep.typeOfDetail==TypeOfDetail.heroPage || ep.typeOfDetail==TypeOfDetail.productCompare){
      src='';
      height=16.0;
    }

    var domImage=src!=''?Image.network(src, fit: BoxFit.cover, height: height, color: Colors.white.withOpacity(0.15),colorBlendMode: BlendMode.lighten,):Container();

    return SliverAppBar(
      pinned: false,
      leading: IconButton(
          icon: Icon(Icons.close),
          color:Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pop(context, 'Nope!');
          }),
      expandedHeight: height,
      elevation: 1.0,
      floating: false,// snap: true,
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

  Widget compareFields() {
    final ThemeData themeData = Theme.of(context);

    var subheadStyle=Theme.of(context).textTheme.subhead;
    var caption=themeData.textTheme.caption;

    List<Widget>sec = new List<Widget>();

    for (int i = 0; i < getEndPoint().fields.length; i++) {
      var attr = getEndPoint().fields[i];
      var att_text = beautifulAttr(attr);

      var value1 = beautifulNumber( valueForField(_card.get(attr)).toString() );
      var value2 = beautifulNumber( valueForField(_cardToCompare.get(attr)).toString() );

      sec.add(
        new Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: new Row(
            children: <Widget>[
              new Expanded(child:new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(value1,   textAlign: TextAlign.left, style: subheadStyle),
                  ]
                ),
              ),
              new Expanded(child:new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Text(att_text, textAlign: TextAlign.left, style: caption,),
                  ],
                ),
              ),
              new Expanded(child:new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(value2),
                    new Text(' ', style: themeData.textTheme.caption,),
                  ],
                ),
              ),
            ],
          ),
        )
      );
    }
    return new Container(child: Column(children: sec,),);
  }

  EndPoint getEndPoint(){
    return appData.getCurrEndPoint();
  }
  navigateImagePage(String url, BuildContext context){
    Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new ImagePage(url:url),
    ));
  }

  Widget posterAndTitleBlock() {
    var ep=getEndPoint();

    var src=_card.get(ep.firstImage());
    var name = _card.get(ep.name);

    return Stack(children: [
      Padding(padding: const EdgeInsets.only(bottom: 200.0)),

      Positioned(
        bottom: 0.0,
        left: 16.0,
        right: 16.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _titleLeftBlock(src, altImage:_card.getImgPlaceholder()),
            SizedBox(width: 16.0),
            _titleRightBlock(name),
          ],
        ),
      ),

    ]);
  }
  Widget _titleLeftBlock(String url, {String altImage}) {
    var width = POSTER_RATIO * POSTER_HEIGHT;

    if (url==null || url=='') url=altImage;

    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
    var domImage=Image.network(url, fit: doesNotWantsBox?BoxFit.contain:BoxFit.cover, width: width, height: POSTER_HEIGHT,);

    return GestureDetector(
        child:doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
        onTap: () {
          if (url!=altImage)
            navigateImagePage(url, context);
        },
    );
  }
  Widget _titleRightBlock(name) {
    var textTheme = Theme.of(context).textTheme;

    return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: textTheme.headline, maxLines: 3, overflow: TextOverflow.ellipsis,),

            SizedBox(height: 8.0),
            _stats(),

            SizedBox(height: 8.0),
            _chips(),
          ],
        )
    );
  }

  Widget sidebyside(Widget left, Widget right){
    return Stack(children: [
      Padding(padding: const EdgeInsets.only(bottom: 220.0)),
      Positioned(
        bottom: 0.0, left: 16.0, right: 16.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            left,
            Expanded(child:Container()),
            right,
          ],
        ),
      )
    ]);
  }
  Widget posterWName(ModelCard newcard, bool isLeft){
    var ep=getEndPoint();

    var url=newcard.get(ep.firstImage());
    var name = newcard.get(ep.name);

    var themeSoft = textTheme.headline;

    var width = POSTER_RATIO * POSTER_HEIGHT;

    if (url==null || url=='') url=_card.getImgPlaceholder();

    var doesNotWantsBox=(url.endsWith('.png'));//assume it's transparent --> no border
    var domImage=new Image.network(url, fit: doesNotWantsBox?BoxFit.scaleDown: BoxFit.cover, width: width, height: POSTER_HEIGHT,);

    return new Column(
      crossAxisAlignment: isLeft?CrossAxisAlignment.start:CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        doesNotWantsBox? domImage: Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
        SizedBox(height: 8.0),
        Text(name, style: themeSoft, textAlign: TextAlign.center),
     ]
    );
  }

  Widget _stats(){
    var ret=<Widget>[];

    var listaAtr=getEndPoint().stats;

    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.textTheme.caption.decorationColor,);
    var themeSoft = textTheme.caption.copyWith(color: theme.textTheme.caption.decorationColor);

    for (var i=0; i<listaAtr.length; i++){
      if (i>0) ret.add( SizedBox(width: 16.0) );

      var att=listaAtr[i];
      var att_text=beautifulAttr(att);

      var value=beautifulNumber( _card.get(att) );

      var numericRating = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: themeBold, textAlign: TextAlign.center,),
          SizedBox(height: 4.0),
          Text(att_text, style: themeSoft,),
        ],
      );

      ret.add(numericRating);
    }

    return SizedBox.fromSize(
        size: const Size.fromHeight(50.0),
        child: ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 0.0, left: 0.0),
          itemBuilder: (BuildContext, index) => ret[index],
        )
    );//Row(crossAxisAlignment: CrossAxisAlignment.end, children: ret);
  }
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
  beautifulNumber(value){
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

  Widget _chips(){
    var ret=<String>[];

    if (getEndPoint().tags==null)
      return Container();

    var chipsAttr=getEndPoint().tags;

    for (var i=0; i<chipsAttr.length; i++){
      var fieldName=chipsAttr[i];
      print (fieldName);
      var values=_card.get(fieldName);

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

    return SizedBox.fromSize(
        size: const Size.fromHeight(40.0),
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
          labelStyle: textTheme.caption,
          backgroundColor: Colors.black12,
        ),
      );
  }

  Widget separator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
      ),
    );
  }

  Widget descWidget(){
    var value=_card.get( getEndPoint().text );

    if (value==null)
      return null;

    var valueStyle=textTheme.body1.copyWith(color: Colors.black45, fontSize: 16.0, );
    var moreStyle= textTheme.body1.copyWith(fontSize: 16.0, color: theme.accentColor);

    return Padding(
        padding: EdgeInsets.only(top:16.0, left: 16.0, right:16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Desc', style: textTheme.subhead.copyWith(fontSize: 18.0),),
            SizedBox(height: 8.0),
            Text(value, style:valueStyle,),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('more', style: moreStyle),
                Icon(Icons.keyboard_arrow_down, size: 18.0, color: theme.accentColor,),
              ],
            ),
          ],
        )
    );
  }

  Widget secondaryFieldsWidget(ModelCard newcard) {
    var sec = <Widget>[];

    for (int i=0; i<getEndPoint().fields.length; i++) {
      var attr=getEndPoint().fields[i];
      var att_text=beautifulAttr(attr);

      var value=newcard.get(attr);

      if (value==null){
        continue;
      }
      else if (value.runtimeType.toString()=='List<dynamic>')
        value=value[0];

      try{
        sec.add(
          new WidgetCategoryItem(
            lines: <String>[value, att_text],
          ),
        );
      } catch(e, s){
//        sec.add( new WidgetCategoryItem(
//          lines: <String>["Error", attr],
//        ),);
      //pass
      }
    }

    if (sec.length==0)
      return null;
    return new WidgetCategory(icon: Icons.edit_attributes, children: sec);
  }

  Widget photoScroller(){
    var ret=<String>[];

    var images=getEndPoint().images;

    if (images==null || images.length<2)
      return null;

    for (var i=0; i<images.length; i++){
      var fieldName=images[i];
      var values=_card.get(fieldName);

      if (values==null){
        //pass
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
    return SizedBox.fromSize(
        size: const Size.fromHeight(140.0),
        child: ListView.builder(
          itemCount: ret.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 8.0, left: 20.0),
          itemBuilder: (BuildContext, index) => _buildPhotoScrollerItem(ret[ret.length-1-index]),
        )
    );
  }
  _buildPhotoScrollerItem(url){
//    var height=180.0;
//    var width = POSTER_RATIO * height;

    if (url=='') return null;

    var el=Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image.network(url, width: 160.0, height: 120.0, fit: BoxFit.cover,),
      ),
    );

    return GestureDetector(
      child:el,
      onTap: () {
        navigateImagePage(url, context);
      },
    );
  }


  void _showSnackbar(String text, BuildContext xcontext) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    Scaffold.of(xcontext).showSnackBar(snackBar);
  }

}
