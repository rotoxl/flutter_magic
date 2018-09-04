import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:magic_flutter/app_data.dart';

import 'package:magic_flutter/ui/card_listing.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var ep=appData.getCurrEndPoint();

    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        brightness: Brightness.light,
        primarySwatch: ep==null?Colors.indigo: ep.color,
        platform: Theme.of(context).platform,
      ),
      home: ep==null?
        Center(child:CircularProgressIndicator() ):
        new CardListingPage(title: ep.title),
    );
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

