import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:app/app_data.dart';
import 'package:flutter/material.dart';

import 'package:app/models/end_point.dart';
import 'package:app/models/model_card.dart';
import 'package:app/ui/image_page.dart';

import 'package:app/ui/widgets.dart';

class DetailPage extends StatefulWidget {
  final ModelCard _card;

  DetailPage(this._card, {Key key}) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState(this._card);
}

class _DetailPageState extends State<DetailPage> {
  final ModelCard _card;

  final appBarHeight = 156.0;
  final POSTER_RATIO = 0.7;

  ThemeData theme;
  TextTheme textTheme;

  _DetailPageState(this._card);

  Future<Null> editAttributes() async {

//    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditDetailsPage( getEndPoint() )) );
//    setState(() {
//      var _endPoint = appData.getCurrEndPoint();
//    });
  }

  @override
  Widget build(BuildContext context) {
    this.theme= Theme.of(context);
    this.textTheme= Theme.of(context).textTheme;

    List<Widget>allWidgets=[
      posterAndTitleBlock(),
      separator(),
    ];

    var d=descWidget();
    if (d!=null){
      allWidgets.add(d);
      allWidgets.add(separator());
    }

    var s=secondaryFieldsWidget();
    if (s!=null){
      allWidgets.add(s);
      allWidgets.add(separator());
    }

    var p=photoScroller();
    if (p!=null){
      allWidgets.add(p);
      allWidgets.add(separator());
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

  Widget appBar() {
    var ep=getEndPoint();
    var src=_card.get(ep.secondImage() );

    if (src==null || src=='') src=_card.getImgPlaceholder();
    var domImage=src!=''?Image.network(src, fit: BoxFit.cover, height: appBarHeight, color: Colors.white.withOpacity(0.55),colorBlendMode: BlendMode.lighten,):Container();

    return SliverAppBar(
      pinned: false,
      leading: IconButton(
          icon: Icon(Icons.close),
          color:Theme.of(context).accentColor,
          onPressed: () {
            Navigator.pop(context, 'Nope!');
          }),
      expandedHeight: appBarHeight,

      floating: false,// snap: true,
      // floating: true, snap: true,

      flexibleSpace: new FlexibleSpaceBar(background: domImage,),
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
            _titleLeftBlock(src, height: 180.0, altImage:_card.getImgPlaceholder()),
            SizedBox(width: 16.0),
            _titleRightBlock(name),
          ],
        ),
      ),

    ]);
  }
  Widget _titleLeftBlock(url, {double height, String altImage}) {
    var width = POSTER_RATIO * height;

    if (url==null || url=='') url=altImage;
    var domImage=Image.network(url, fit: BoxFit.cover, width: width, height: height,);

    return GestureDetector(
        child:Material(borderRadius: BorderRadius.circular(4.0), elevation: 5.0, child: domImage),
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
            Text(name, style: textTheme.headline,),

            SizedBox(height: 8.0),
            _stats(),

            SizedBox(height: 8.0),
            _chips(),
          ],
        )
    );
  }

  Widget _stats(){
    var ret=<Widget>[];

    var listaAtr=getEndPoint().stats;

    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.accentColor,);
    var themeSoft = textTheme.caption.copyWith(color: Colors.black45);

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
      var sep=null;
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

  Widget secondaryFieldsWidget() {
    var sec = <Widget>[];

    for (int i=0; i<getEndPoint().fields.length; i++) {
      var attr=getEndPoint().fields[i];
      var value=_card.get(attr);

      if (value==null){
        continue;
      }
      else if (value.runtimeType.toString()=='List<dynamic>')
        value=value[0];

      try{
        sec.add(
          new WidgetCategoryItem(
            lines: <String>[value, attr],
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
    var height=180.0;
    var width = POSTER_RATIO * height;

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
