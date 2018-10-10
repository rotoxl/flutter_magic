import 'package:app/models/end_point.dart';
import 'package:app/ui/app_data_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app/app_data.dart';
import 'package:app/ui/card_listing.dart';
import 'package:app/ui/config.dart';

import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{
  AppData appData;

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = new FirebaseAnalytics();

    this.appData=appData;

    var routes=<String, WidgetBuilder>{
      '/':(BuildContext context){
                      return new AppDataXLoader(themeUpdater, analytics);
                    },
      '/cardlisting':(BuildContext context){
                        return new CardListing(themeUpdater);
                      },
      '/config': (BuildContext context) => new ConfigPage(themeUpdater),
    };

    return new MaterialApp(
        debugShowCheckedModeBanner:false,
        title: 'API Explorer',
        theme: theme,
        navigatorObservers: [
          new FirebaseAnalyticsObserver(analytics: analytics),
        ],
        routes: routes,
        onGenerateRoute: _getRoute,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void themeUpdater(AppData newappData) {
    setState(() {
      this.appData=newappData;

      var ep=this.appData!=null?this.appData.getCurrEndPoint():null;
      if (ep!=null)
        appData.themeApplied=ep.epTheme;
    });
  }
  ThemeData get theme{
    EndPoint ep;
    if (this.appData!=null && this.appData.getCurrEndPoint()!=null)
      ep=this.appData.getCurrEndPoint();

    if (ep!=null && ep.epTheme!=null){
      return ep.epTheme.theme;
    }
    else {
      return
        new ThemeData(
          brightness: Brightness.light,
          primarySwatch: ep==null?Colors.indigo: ep.epTheme.color,
          platform: Theme.of(context).platform,
        );
    }
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not emfpty:
    if (path[0] != '')
      return null;
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

