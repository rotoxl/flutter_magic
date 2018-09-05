import 'package:flutter/material.dart';
import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/models/end_point.dart';
import 'package:magic_flutter/models/model_card.dart';
import 'package:magic_flutter/ui/card_details.dart';

import 'package:magic_flutter/ui/config.dart';

enum Mode { list, grid }

class CardListingPage extends StatefulWidget {
  CardListingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CardListingPageState createState() => new _CardListingPageState(Mode.grid);
}

class _CardListingPageState extends State<CardListingPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = null;

  EndPoint ep;
  var _cards = <ModelCard>[];
  Mode mode;
  bool modeChangedAtRunTime = false;

  _CardListingPageState(this.mode);

  @override
  Widget build(BuildContext context) {
    this._scaffoldKey = new GlobalKey<ScaffoldState>();
    ep = appData.getCurrEndPoint();

    return new Scaffold(
      key: this._scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  _buildAppBar(BuildContext context) {
    return new AppBar(title: new Text(widget.title), actions: <Widget>[
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Config()),
          );
        },
      ),
    ]);
  }

  _buildBody(BuildContext context) {
    if (this._cards.length > 0) {
      return _buildGridOrList(context);
    } else {
      return FutureBuilder<List<ModelCard>>(
          future: fetchPost(appData.getCurrEndPoint()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              this._cards = snapshot.data;
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
    return ListTile(
      title: Text(
        card.get(ep.nameField),
        style: Theme.of(context).textTheme.title,
      ),
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
    var src=card.get(this.ep.imgField);
    var txt=card.get(this.ep.nameField);

    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.title;

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
                      new Positioned.fill(child: Image.network(src, fit: BoxFit.contain), bottom:10.0,),

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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailPage(card, appData.getCurrEndPoint())),
    );
  }

  void _showSnackbar(String text) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    if (this._scaffoldKey != null && this._scaffoldKey.currentState != null)
      this._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
