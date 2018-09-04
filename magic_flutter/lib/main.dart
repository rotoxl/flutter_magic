import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:magic_flutter/model.dart';
import 'package:magic_flutter/widgets.dart';
import 'package:magic_flutter/dialog_editDetails.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    EndPoint ep=appData.getCurrEndPoint();

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        brightness: Brightness.light,
        primarySwatch: ep==null?
          Colors.indigo:
          ep.color,
        platform: Theme.of(context).platform,
      ),
      home: ep==null?
        Center(child:CircularProgressIndicator() ):
        new CardListingPage(title: ep.title),
    );
  }
}

class CardListingPage extends StatefulWidget {
  CardListingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CardListingPageState createState() => new _CardListingPageState();
}
class _CardListingPageState extends State<CardListingPage> {
  var _cards = <ModelCard>[];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                appData.save();
              },
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () {
                print (appData.loadEndPoints());
              },
            ),
          ]
      ),
      body: _buildBody(context),


//      floatingActionButton: new FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: new Icon(Icons.add),
//      ),
    );
  }

  _buildBody(BuildContext context) {
    return FutureBuilder<List<ModelCard>>(future: fetchPost(), builder: (context, snapshot) {
      if (snapshot.hasData) {
        this._cards=snapshot.data;
        return _buildList(context);
      } else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }

      // By default, show a loading spinner
      return Center(child:CircularProgressIndicator() );
    });
  }

  _buildList(BuildContext context) {
//    if (_cards.length==0) generateMockData();
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:(_cards.length*2)-1,
        itemBuilder: (context, index) {
          if (index.isOdd)
            return Divider();
          else
            return _buildRow(_cards[index ~/ 2], context);
        });

  }
  _buildRow(ModelCard card, BuildContext context){
    return ListTile(
      title: Text(card.get("name"), style: Theme.of(context).textTheme.title,),
      trailing: Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor,),
      onTap: () {
//        Scaffold.of(context).showSnackBar(SnackBar(content:Text(card.name)));

        _navigateDetailPage(card, context);

      },
    );
  }

   _navigateDetailPage(ModelCard card, BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(card, appData.getCurrEndPoint())),
      );
  }

}

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
      MaterialPageRoute(builder: (context) => FullScreenDialogDemo(this._endPoint)),
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



////////////////////////

/*
Future<Null> editAttrList_dialog() async {
  void onSubmit(String result) {
    print(result);
  }
  var dialog=Dialog_chooseOne(onSubmit:onSubmit, options:ModelCard.members);

  var response=await showDialog<List>(
      context: context,
      builder: (BuildContext context) => dialog
  );

  print (response!=null? response[0]: 'No hay respuesta');
}
*/
typedef void _DialogChooseOneCallback(String result);
class DialogChooseOne extends StatefulWidget{
  final _DialogChooseOneCallback onSubmit;
  final List<String> options;

  DialogChooseOne({this.onSubmit, this.options});

  @override
  _DialogChooseOneState createState() => new _DialogChooseOneState(this.options);
}
class _DialogChooseOneState extends State<DialogChooseOne> {
  final List<String> options;
  Map<String, bool> chosenValues = {'name': true, 'id': true,};

  _DialogChooseOneState(this.options);

  @override
  Widget build(BuildContext context) {
    var w=List<Widget>();
    for (var i=0; i<this.options.length; i++){
      var key=options[i];

      w.add(
        SimpleDialogOption(
          onPressed: () {
            widget.onSubmit(key);

            var retPop=List<dynamic>();
            retPop.add(key);

            Navigator.pop(context, retPop);
          },
          child:ListTile(
              title:Text(key)
          ),
        ),
      );
    }

    return new SimpleDialog(
        title: new Text("Choose field"),
        children: w,
        );
  }
}

