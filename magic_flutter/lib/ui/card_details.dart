import 'dart:async';

import 'package:flutter/material.dart';

import 'package:magic_flutter/models/end_point.dart';
import 'package:magic_flutter/models/model_card.dart';

import 'package:magic_flutter/ui/widgets.dart';
import 'package:magic_flutter/ui/card_details_edit.dart';

import 'package:magic_flutter/app_data.dart';

class DetailPage extends StatefulWidget{
  final ModelCard _card;
  final EndPoint _endPoint;

  DetailPage(this._card, this._endPoint, {Key key}) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState(this._card, this._endPoint);
}
class _DetailPageState extends State<DetailPage>{
  final ModelCard _card;
  EndPoint _endPoint;

  final appBarHeight=306.0;
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
      this._endPoint=appData.getCurrEndPoint();
    });
  }
  @override
  Widget build(BuildContext context) {
//    var _showTitle=true;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            leading: IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.pop(context, 'Nope!');},),
            expandedHeight: appBarHeight,

            floating:true,
            snap:true,

            flexibleSpace: new FlexibleSpaceBar(
              //title: Text(_card.name),
              background: Image.network(_card.get(this._endPoint.imgField), fit: BoxFit.cover, height: appBarHeight, color: Colors.grey.withOpacity(0.95), colorBlendMode: BlendMode.lighten,),
            ),
            actions: <Widget>[
              new IconButton(
                icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: () {this.editAttributes();},
              ),
            ],
          ),
          SliverList(
            delegate: new SliverChildListDelegate(this.buildAttrList()),
          ),
        ],
      ),
    );
  }

  List<Widget> buildAttrList(){

    var pri=<Widget>[];
    for (String attr in this._endPoint.mainFields){
      pri.add(
        new WidgetCategoryItem(lines: <String>[_card.get(attr), attr],),
      );
    }

    var sec=<Widget>[];
    for (String attr in this._endPoint.secondaryFields){
      sec.add(
        new WidgetCategoryItem(
//            icon: Icons.account_circle,
//            onPressed: (BuildContext context) {this._showSnackbar('Should search for more art by this artist.', context); return true;},
          lines: <String>[_card.get(attr), attr],
        ),
      );
    }

    var ret=<Widget>[];
    ret.add(new WidgetCategory(icon: Icons.event_note, children: pri));
    ret.add(new WidgetCategory(icon: Icons.edit_attributes, children: sec), );

    return ret;
  }
  void _showSnackbar(String text, BuildContext xcontext){
    final snackBar = SnackBar(content: Text(text), duration: Duration(seconds: 3));
    Scaffold.of(xcontext).showSnackBar(snackBar);
  }
}

