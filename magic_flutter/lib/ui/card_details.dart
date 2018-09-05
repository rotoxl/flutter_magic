import 'dart:async';

import 'package:flutter/material.dart';

import 'package:magic_flutter/models/end_point.dart';
import 'package:magic_flutter/models/model_card.dart';

import 'package:magic_flutter/ui/widgets.dart';
import 'package:magic_flutter/ui/card_details_edit.dart';

import 'package:magic_flutter/app_data.dart';

class DetailPage extends StatefulWidget {
  final ModelCard _card;
  final EndPoint _endPoint;

  DetailPage(this._card, this._endPoint, {Key key}) : super(key: key);

  @override
  _DetailPageState createState() =>
      new _DetailPageState(this._card, this._endPoint);
}

class _DetailPageState extends State<DetailPage> {
  final ModelCard _card;
  EndPoint _endPoint;

  final appBarHeight = 156.0;
  final POSTER_RATIO = 0.7;

  ThemeData theme;
  TextTheme textTheme;

//  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _DetailPageState(this._card, this._endPoint);

  Future<Null> editAttributes() async {
//    void onSubmit(String result) {
//      print(result);
//    }
//    var dialog=Dialog_chooseOne(onSubmit:onSubmit, options:ModelCard.members);
//
//    var response=await showDialog<List>(
//        context: context,
//        builder: (BuildContext context) => dialog
//    );
//
//    print (response!=null? response[0]: 'No hay respuesta');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDetailsPage(this._endPoint)),
    );

    setState(() {
      this._endPoint = appData.getCurrEndPoint();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.theme= Theme.of(context);
    this.textTheme= Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar(),
          SliverList(
            delegate:
                new SliverChildListDelegate(<Widget>[
                  posterAndTitleBlock(),

                  separator(),
                  descWidget(),

                  separator(),
                  secondaryFieldsWidget(),
                ]),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return SliverAppBar(
      pinned: false,
      leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, 'Nope!');
          }),
      expandedHeight: appBarHeight,

      floating: false,// snap: true,
      // floating: true, snap: true,

      flexibleSpace: new FlexibleSpaceBar(
        background: Image.network(
          _card.get(this._endPoint.imgField),
          fit: BoxFit.cover,
          height: appBarHeight,
          color: Colors.white.withOpacity(0.55),
          colorBlendMode: BlendMode.lighten,
        ),
      ),
      actions: <Widget>[
        new IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              this.editAttributes();
            }),
      ],
    );
  }

  Widget posterAndTitleBlock() {
    var src = _card.get(this._endPoint.imgField);
    var name = _card.get(this._endPoint.nameField);

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
            _titleLeftBlock(src, height: 180.0,),
            SizedBox(width: 16.0),
            _titleRightBlock(name),
          ],
        ),
      ),

    ]);
  }
  Widget _titleLeftBlock(url, {double height}) {
    var width = POSTER_RATIO * height;
    return Material(
      borderRadius: BorderRadius.circular(4.0),
      elevation: 5.0,
      child: Image.network(url, fit: BoxFit.cover, width: width, height: height,),
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

    var listaAtr=["toughness", "power", "cmc"];

    var themeBold=textTheme.headline.copyWith(fontWeight: FontWeight.w400, color: theme.accentColor,);
    var themeSoft = textTheme.caption.copyWith(color: Colors.black45);

    for (var i=0; i<listaAtr.length; i++){
      if (i>0) ret.add( SizedBox(width: 16.0) );

      var att=listaAtr[i];
      var value=_card.get(att).toString();

      var numericRating = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: themeBold, textAlign: TextAlign.center,),
          SizedBox(height: 4.0),
          Text(att, style: themeSoft,),
        ],
      );

      ret.add(numericRating);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: ret);
  }
  Widget _chips(){
//    var ret=<Widget>[];
    var ret=<String>[];

    var chipsAttr=['types', "subtypes"];

    for (var i=0; i<chipsAttr.length; i++){
      var fieldName=chipsAttr[i];
      var values=_card.get(fieldName);

      for (var j=0; j<values.length; j++) {
        var value=values[j];
        ret.add(value);
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
    var value=_card.get("text");
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
  Widget mainFieldsWidget(){
    var pri = <Widget>[];
    for (String attr in this._endPoint.mainFields){
      pri.add(
        new WidgetCategoryItem(lines: <String>[_card.get(attr), attr],),
      );
    }
    return new WidgetCategory(icon: Icons.event_note, children: pri);
  }
  Widget secondaryFieldsWidget() {
    var sec = <Widget>[];

    for (String attr in this._endPoint.secondaryFields) {
      sec.add(
        new WidgetCategoryItem(
          lines: <String>[_card.get(attr), attr],
        ),
      );
    }

//    ret.add(new WidgetCategory(icon: Icons.event_note, children: pri));
    return new WidgetCategory(icon: Icons.edit_attributes, children: sec);
  }

  void _showSnackbar(String text, BuildContext xcontext) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    Scaffold.of(xcontext).showSnackBar(snackBar);
  }

}
