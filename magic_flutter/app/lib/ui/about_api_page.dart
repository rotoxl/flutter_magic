import 'dart:async';

import 'package:app/models/end_point.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


enum Type{sep, link, endPoint}

class AboutAPIPage {
  EndPoint ep;

  TextTheme textTheme;
  TextStyle linkStyle, aboutStyle;

  AboutAPIPage(this.ep);

  Future<Null> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    }
  }

  customDialogShow(BuildContext context){
    this.textTheme= Theme.of(context).textTheme;
    this.linkStyle=this.textTheme.button.copyWith(color: Colors.black);
    this.aboutStyle=this.textTheme.subhead.copyWith(color: Colors.black54);

    Widget dom=_getDom(context);

    var fnCallBack=(response){
      print('You selected: $response');
    };
    _doShowDemoDialog(context:context, child:dom, fnCallBack:fnCallBack);
  }

  Widget _getDom(BuildContext context){
//    final ThemeData theme = Theme.of(context);

    var txt=Text(this.ep.aboutInfo, softWrap:true, style:this.aboutStyle, overflow: TextOverflow.ellipsis, maxLines: 3,);

    var col1;
    if (this.ep.aboutLogo!=null){
      col1=Image.network(this.ep.aboutLogo, fit: BoxFit.cover, width: 100.0, height: 100.0);
    }
    else{
      col1=Container(constraints: BoxConstraints(minWidth:100.0, minHeight: 100.0),
                    child: new Icon(Icons.info_outline, color:Colors.black45, size: 90.0) );
    }

    var col2=new Container(
      height: 100.0,
      width: 180.0,
      child: Padding(
          padding:EdgeInsets.symmetric(horizontal:8.0),
          child:Center(
              child: txt
          )
      ),
    );

    var fl1=Flex(
      direction:Axis.horizontal ,
      children: <Widget>[
        new Row(children: <Widget>[
          col1, col2
        ]),
      ],
    );

    Widget dom = new SimpleDialog(
        titlePadding: const EdgeInsets.all(0.0),
        contentPadding: const EdgeInsets.all(0.0),
        children: <Widget>[
          new Container(
              color:Colors.white,
              child:Column(
                children: <Widget>[
                  fl1,
                ],
              )
          ),
          new Container(
              color:Colors.white,
              padding:EdgeInsets.symmetric(horizontal: 0.0, vertical:4.0,),
//              color:Colors.red,
              child:Column(
                children: <Widget>[
                  _link(this.ep.aboutWeb, this.ep.aboutWeb),
                  _link(this.ep.aboutDoc, 'Visit docs')
                ],
              )
          ),

        ]);
    return dom;
  }

  _link(String url, text) {
    var sd=new SimpleDialogOption(
      onPressed:()=>_openURL(url),
          child:Row(
              mainAxisSize:MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(text, style: this.linkStyle, overflow: TextOverflow.ellipsis, ),
                new Align(alignment:Alignment.bottomRight, child: Icon(Icons.chevron_right, color:Colors.black45))
              ]
          )
    );
    return sd;
  }
  _doShowDemoDialog<T>({ BuildContext context, Widget child, Null Function(String response) fnCallBack }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) { // The value passed to Navigator.pop() or null.
      fnCallBack(value.toString());
    });
  }

}
