import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/models/end_point.dart';

class ConfigPage extends StatefulWidget {
  final HashMap<String, dynamic> _config;
  void Function(HashMap<String, dynamic> newValue) _updater;

  ConfigPage(this._config, void Function(HashMap<String,dynamic> newValue) this._updater);

  @override
  _ConfigPageState createState() => new _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;

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
  //        IconButton(icon: const Icon(Icons.save),onPressed: () {appData.save();},),
  //        IconButton(icon: const Icon(Icons.folder_open),onPressed: () {print(appData.loadEndPoints());},),
            IconButton(icon: const Icon(Icons.add), onPressed: () {this._showSnackbar('Not implemented yet');},),
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
    var row=ListTile(
      title: Text(ep.endpointTitle, style: Theme.of(context).textTheme.body1,),
      trailing: Icon(Icons.brightness_1, color: ep.color,),
    );

    return new GestureDetector(
      child:row,
      onTap: () {
        appData.setCurrEndPoint(ep.endpointTitle);
        widget._config['ep']=appData.getCurrEndPoint();

        if (widget._updater != null)
          widget._updater(widget._config);//para forzar el tema

        Navigator.pop(context, true);
      },
    );
  }

  void _showSnackbar(String text){
    final snackBar = SnackBar(content: Text(text), duration: Duration(seconds: 3));
    this._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
