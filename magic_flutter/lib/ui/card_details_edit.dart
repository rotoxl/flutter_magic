import 'package:flutter/material.dart';
import 'package:magic_flutter/app_data.dart';
import 'package:magic_flutter/models/end_point.dart';

class EditDetailsPage extends StatefulWidget {
  final EndPoint endPoint;
  EditDetailsPage(this.endPoint, {Key key}) : super(key: key);

  @override
  EditDetailsPageState createState() =>
      new EditDetailsPageState(endPoint);
}
class EditDetailsPageState extends State<EditDetailsPage> {
  EndPoint endPoint;

  String _fieldID, _fieldName, _fieldImage;
  String _fieldMain, _fieldSecondary;

  final TextEditingController _fieldNameController = new TextEditingController();
  final TextEditingController _fieldMainController = new TextEditingController();
  final TextEditingController _fieldSecondaryController = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  EditDetailsPageState(this.endPoint);

  @override
  void initState() {
    _fieldName = this.endPoint.nameField;

    _fieldID = this.endPoint.idField;
    _fieldImage = this.endPoint.imgField;

    _fieldMain = this.endPoint.mainFields.join(", ");
    _fieldSecondary= this.endPoint.secondaryFields.join(", ");

    _fieldNameController.text = _fieldName;
    _fieldMainController.text = _fieldMain;
    _fieldSecondaryController.text = _fieldSecondary;

    return super.initState();
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
    } else {
      form.save();

      this.endPoint.idField=_fieldID;
      this.endPoint.imgField=_fieldImage;
      this.endPoint.nameField=_fieldName;

      var mainTemp=_fieldMain.split(",").map( (s) => s.trim() );
      var secTemp=_fieldSecondary.split(",").map( (s) => s.trim() );

      this.endPoint.mainFields=mainTemp.toList();
      this.endPoint.secondaryFields=secTemp.toList();

      appData.save().then((result) {
        print("Saving done: ${result}.");
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    //
    var listItems = endPoint.fields().map((String value) {
      return new DropdownMenuItem<String>(
        value: value,
        child: new Text(value),
      );
    }).toList();

    return new Scaffold(
      appBar:new AppBar(
          title: new Text('Edit details page'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('SAVE'),
                onPressed: () {
                  _handleSubmitted();
                })
          ]
        ),
      body: new Form(
          key: _formKey,
//          autovalidate: _autovalidate,
//          onWillPop: _warnUserAboutInvalidData,
          child: new ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: new Row(
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              'ID Field',
                              style: theme.textTheme.caption,
                              textAlign: TextAlign.start,
                            ),
                            new DropdownButton(
                                items: listItems,
                                value: _fieldID,
                                onChanged: (String value) {
                                  setState(() {
                                    _fieldID = value;
                                  });
                                }),
                          ],
                        ),
                        new Expanded(child:
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text(
                                  'Image Field',
                                  style: theme.textTheme.caption,
                                  textAlign: TextAlign.start,
                                ),
                                new DropdownButton(
                                    items: listItems,
                                    value: _fieldImage,
                                    onChanged: (String value) {
                                      setState(() {
                                        _fieldImage = value;
                                      });
                                    }),
                              ],
                            )
                          ],
                        )
                        )
                      ],
                    )),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: new TextField(
                        decoration: const InputDecoration(labelText: 'Name field', hintText: 'field1',),
                        autocorrect: false,
                        controller: _fieldNameController,
                        onChanged: (String value) {
                          setState(() {
                            _fieldName = value;
                          });
                        })),               new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: new TextField(
                        decoration: const InputDecoration(labelText: 'Main section fields (CSV)', hintText: 'field1, field2',),
                        autocorrect: false,
                        controller: _fieldMainController,
                        onChanged: (String value) {
                          setState(() {
                            _fieldMain = value;
                          });
                        })),
                new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: new TextField(
                        decoration: const InputDecoration(labelText: 'Secondary section fields (CSV)', hintText: 'field1, field2',),
                        autocorrect: false,
                        controller: _fieldSecondaryController,
                        onChanged: (String value) {
                          setState(() {
                            _fieldSecondary = value;
                          });
                        })),
              ].map((Widget child) {
                return new Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 96.0,
                    child: child);
              }).toList())),
    );
  }
}
