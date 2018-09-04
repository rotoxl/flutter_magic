import 'package:flutter/material.dart';
import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/models/model_card.dart';
import 'package:magic_flutter/ui/card_details.dart';

import 'package:magic_flutter/ui/config.dart';

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
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Config()),);
              },
            ),

          ]
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return FutureBuilder<List<ModelCard>>(future: fetchPost(appData.getCurrEndPoint()), builder: (context, snapshot) {
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
