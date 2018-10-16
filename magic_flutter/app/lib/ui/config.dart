import 'package:app/ui/card_listing.dart';
import 'package:flutter/material.dart';
import 'package:app/app_data.dart';
import 'package:app/models/end_point.dart';

class ConfigPage extends StatefulWidget {
  void Function(AppData p) _themeUpdater;

  ConfigPage(void Function(AppData p) this._themeUpdater);

  @override
  _ConfigPageState createState() => new _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;

  TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    this._scaffoldKey = new GlobalKey<ScaffoldState>();
    this.textTheme=Theme.of(context).textTheme;

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
            IconButton(icon: const Icon(Icons.add), onPressed: () {this.endPointAdd();},),
            IconButton(icon: const Icon(Icons.cloud_download), onPressed: () {this.endPointsRefresh();},),
          ]
      );
  }
  _buildList(BuildContext context) {
    var _endpoints=appData.endPoints().values.toList();
    _endpoints.sort((EndPoint a, EndPoint b) => a.endpointUrl.compareTo(b.endpointUrl) );

    return ListView.builder(
        padding: const EdgeInsets.all(0.0),
        itemCount:(_endpoints.length*2)-1,
        itemBuilder: (context, index) {
          if (index.isOdd)
            return Divider();
          else
            return _buildRow(_endpoints[index ~/ 2], context);
        });
  }
  Widget _buildChip(String value) {
    return Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: Chip(
          labelPadding: EdgeInsets.symmetric(horizontal:0.0, vertical:0.0, ) ,
          labelStyle: this.textTheme.caption,
          label: Text(value),
          backgroundColor: Colors.black12,
        ),
      );
  }
  _buildRow(EndPoint ep, BuildContext context){
    var l=<Widget>[];
    for (var i=0; i<ep.categories.length; i++){
      l.add(_buildChip( ep.categories[i] ));
    }
    var chips=Container(child:Row(children:l));

    var row=Row(
      children:<Widget>[
        SizedBox(width: 20.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              chips,
              Text(ep.endpointTitle, style:this.textTheme.subhead),
            ],
          ),
        ),
        Container(
          width:26.0,
          child:Icon(Icons.brightness_1, color: ep.epTheme.color,),
        ),
        SizedBox(width: 16.0,),
      ]
    );

    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      child:row,
      onTap: () {
        var curr_ep=appData.getFixedEndPoint();

        appData.setCurrEndPoint(ep.endpointTitle);

        appData.logEvent('endpoint_select', {'title': ep.endpointTitle,});

        if (curr_ep==null){
          Navigator.pushReplacement(context, new MaterialPageRoute(
              builder: (BuildContext context){
                return new CardListing(widget._themeUpdater);
              }
          ));
        }
        else
          Navigator.pop(context);
      },
    );
  }

  void endPointAdd() async{
    appData.logEvent('endpoint_add', {'err': 'not-implemented',});
    this._showSnackbar('Not implemented yet');
  }
  void _showSnackbar(String text){
    final snackBar = SnackBar(content: Text(text), duration: Duration(seconds: 3));
    this._scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void endPointsRefresh() async{
    appData.loadEndPoints(); //this only makes sense while debuggin' remoteConfig
  }
}
