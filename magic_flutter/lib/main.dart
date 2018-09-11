import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/ui/card_details.dart';
import 'package:magic_flutter/ui/card_listing.dart';
import 'package:magic_flutter/ui/config.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{
  HashMap<String, dynamic> _config = new HashMap<String, dynamic>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      routes: <String, WidgetBuilder>{
        '/':         (BuildContext context) => new CardListing(_config),     //_config
//        '/detail': (BuildContext context) => new DetailPage(null, _config), //_card, _config
        '/config': (BuildContext context) => new ConfigPage(_config, configurationUpdater),
      },
      onGenerateRoute: _getRoute,
    );
  }

  @override
  void initState() {
    super.initState();
    _config['ep']=appData.getCurrEndPoint();
  }

  void configurationUpdater(HashMap<String, dynamic> value) {
    setState(() {
      _config = value;
    });
  }
  ThemeData get theme{
    var ep=_config['ep'];

    return new ThemeData(
      brightness: Brightness.light,
      primarySwatch: ep==null?Colors.indigo: ep.color,
      platform: Theme.of(context).platform,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '')
      return null;

    // If the path is "/stock:..." then show a stock page for the
    // specified stock symbol.
    if (path[1].startsWith('details:')) {
      // We don't yet support subpages of a stock, so bail if there's
      // any more path components.
      if (path.length != 2)
        return null;
      // Extract the symbol part of "stock:..." and return a route
      // for that symbol.
      final String symbol = path[1].substring(6);

      //TODO get card
      var _card=null;
      return new MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => new DetailPage(_card, _config),
      );
    }
    // The other paths we support are in the routes table.
    return null;
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

