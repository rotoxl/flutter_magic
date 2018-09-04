import 'package:flutter/material.dart';
import 'package:magic_flutter/models/end_point.dart';
import 'package:magic_flutter/models/model_card.dart';

class WidgetCategory extends StatelessWidget {
  const WidgetCategory({ Key key, this.icon, this.children }) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: new BoxDecoration(
          border: new Border(bottom: new BorderSide(color: themeData.dividerColor))
      ),
      child: new DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: new SafeArea(
          top: false,
          bottom: false,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: 72.0,
                  child: new Icon(icon, color: themeData.primaryColor)
              ),
              new Expanded(child: new Column(children: children))
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetCategoryItem extends StatelessWidget {
  WidgetCategoryItem({ Key key, this.icon, this.lines, this.tooltip, this.onPressed })
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final Function(BuildContext) onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> columnChildren = lines.sublist(0, lines.length - 1).map((String line) => new Text(line)).toList();
    columnChildren.add(new Text(lines.last, style: themeData.textTheme.caption));

    final List<Widget> rowChildren = <Widget>[
      new Expanded(
          child: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: columnChildren)
      )
    ];

    rowChildren.add(new SizedBox(
        width: 72.0,
        child: icon!=null?
          new IconButton(icon: new Icon(icon), color: themeData.primaryColor, onPressed: (){onPressed(context);}):
          Text(" ")
    ));

    return new MergeSemantics(
      child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren
          )
      ),
    );
  }
}

class WidgetCirclesScroller extends StatelessWidget {
  EndPoint ep; ModelCard card;

  WidgetCirclesScroller({ Key key, this.card, this.ep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16.0),
      scrollDirection: Axis.horizontal,
      itemCount: ep.statsFields.length,
      itemBuilder: (BuildContext context, int index) {
        var field = this.ep.statsFields[index];
        return _buildListItem(context, this.card, field);
      },
    );
  }

  Widget _buildListItem(BuildContext context, ModelCard card, String field) {
    var value=card.get(field);

    return Container(
        width: 90.0,
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: <Widget>[
            Text(value, style: const TextStyle(fontSize: 18.0),),
            const SizedBox(height: 8.0),
            Text(field, style: const TextStyle(fontSize: 12.0),),
          ],
        ),
      );
    }
}