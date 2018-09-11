import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:magic_flutter/models/end_point.dart';
import 'package:magic_flutter/models/model_card.dart';
import 'package:magic_flutter/ui/card_details.dart';

import 'package:magic_flutter/ui/config.dart';

enum Mode { list, grid }

class CardListing extends StatefulWidget {
  final HashMap<String, dynamic> _config;

  const CardListing(this._config);

  @override
  _CardListingState createState() => new _CardListingState(Mode.grid, this._config);
}

class _CardListingState extends State<CardListing> {
  final HashMap<String, dynamic> _config;

  GlobalKey<ScaffoldState> _scaffoldKey = null;

  EndPoint ep;
  Mode mode;
  bool modeChangedAtRunTime = false;

  _CardListingState(this.mode, this._config);

  EndPoint getEndPoint(){
    return this._config["ep"];
  }
  epCards(){
    return getEndPoint().cards;
  }

  @override
  Widget build(BuildContext context) {
    this._scaffoldKey = new GlobalKey<ScaffoldState>();
    ep = getEndPoint();

    return new Scaffold(
      key: this._scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  _buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text(ep.endpointTitle),

        actions: <Widget>[
          IconButton(
            icon:
                Icon(this.mode == Mode.list ? Icons.view_module : Icons.view_list),
            onPressed: () {
              setState(() {
                if (this.mode == Mode.list)
                  this.mode = Mode.grid;
                else
                  this.mode = Mode.list;

                modeChangedAtRunTime = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/config');

//              setState(() {
//                var ep=getEndPoint();
//                _cards.clear();
//              });


            },
          ),
    ]);
  }

  _buildBody(BuildContext context) {
    var _cards=epCards();

    if (_cards.length > 0) {
      return _buildGridOrList(context);
    } else {
      var ep=getEndPoint();

      return FutureBuilder<List<ModelCard>>(
          future: fetchPost(ep),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              ep.cards = snapshot.data;
              return _buildGridOrList(context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner
            return Center(child: CircularProgressIndicator());
          });
    }
  }

  _buildGridOrList(BuildContext context) {
    if (this.mode == Mode.list)
      return _buildList(context);
    else
      return _buildGrid(context);
  }

  _buildList(BuildContext context) {
    var _cards=epCards();

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: (_cards.length * 2) - 1,
        itemBuilder: (context, index) {
          if (index.isOdd)
            return Divider();
          else
            return _buildRow(_cards[index ~/ 2], context);
        });
  }
  _buildRow(ModelCard card, BuildContext context) {
    var txt=card.get(this.ep.name);
    if (txt==null){
      txt="Campo no informado: ${this.ep.name}";
    }

    return ListTile(
      title: Text(txt, style: Theme.of(context).textTheme.title,),
      trailing: Icon(
        Icons.panorama_fish_eye,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () {
//        Scaffold.of(context).showSnackBar(SnackBar(content:Text(card.name)));

        _navigateDetailPage(card, context);
      },
    );
  }

  _buildGrid(BuildContext context) {
    var _cards=epCards();
    return new GridView.builder(
        primary: true,
        padding: const EdgeInsets.all(0.0),
        itemCount: _cards.length,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return _buildGridItem(_cards[index], context);
        });
  }
  _buildGridItem(ModelCard card, BuildContext context) {
    var fi=card.get(this.ep.firstImage());
    var src=(fi!=null?fi:'');

    var txt=card.get(this.ep.name);
    if (txt==null){
      txt="Campo no informado: ${this.ep.name}";
    }

    var domImg=src==''?Container() :Image.network(src, fit: BoxFit.contain);

    final ThemeData theme = Theme.of(context);
//    final TextStyle textStyle = theme.textTheme.title;

    var domcard=new Card(
        elevation: 0.5,
        child: new SizedBox(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                new SizedBox(
                  height: 155.0,
                  child:new Stack(
                    children: <Widget>[
                      new Positioned.fill(child:domImg, bottom:10.0,),

                    ],
                  )
                ),

                new Flexible(child: new Text(txt, textAlign:TextAlign.center, overflow: TextOverflow.ellipsis,),)
              ],
            )
        )
    );

    return new GestureDetector(
      child:domcard,
      onTap: () {
        _navigateDetailPage(card, context);
      },
    );

  }

  _navigateDetailPage(ModelCard card, BuildContext context) async {
//    Navigator.pushNamed(context, '/detail');//no se puede usar pushNamed porque no recibe ningún otro parámetro

    Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new DetailPage(card, this._config),
    ));
  }

  void _showSnackbar(String text) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    if (this._scaffoldKey != null && this._scaffoldKey.currentState != null)
      this._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
