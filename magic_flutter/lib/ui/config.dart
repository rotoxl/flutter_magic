import 'package:flutter/material.dart';
import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/models/end_point.dart';

class Config extends StatelessWidget {
  GlobalKey<ScaffoldState> _scaffoldKey;

  Config({Key key});

  @override
  Widget build(BuildContext context) {
    this._scaffoldKey = new GlobalKey<ScaffoldState>();

    return new Scaffold(
      key: this._scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildList(context),
    );
  }

  _buildAppBar(BuildContext context){
    return AppBar(
          title: new Text('Choose endpoint'),
          actions: <Widget>[
  //            IconButton(
  //              icon: const Icon(Icons.save),
  //              onPressed: () {
  //                appData.save();
  //              },
  //            ),
  //            IconButton(
  //              icon: const Icon(Icons.folder_open),
  //              onPressed: () {
  //                print(appData.loadEndPoints());
  //              },
  //            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              this._showSnackbar('Not implemented yet');
            },
          ),
          ]
      );
  }
  _buildList(BuildContext context) {
    var _endpoints=appData.endPoints().values.toList();

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:(_endpoints.length*2)-1,
        itemBuilder: (context, index) {
          if (index.isOdd)
            return Divider();
          else
            return _buildRow(_endpoints[index ~/ 2], context);
        });
  }
  _buildRow(EndPoint ep, BuildContext context){
    return ListTile(
      title: Text(ep.title, style: Theme.of(context).textTheme.title,),
      trailing: Icon(Icons.http, color: Theme.of(context).primaryColor,),
    );
  }

  void _showSnackbar(String text){
    final snackBar = SnackBar(content: Text(text), duration: Duration(seconds: 3));
    this._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
