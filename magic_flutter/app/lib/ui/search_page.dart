import 'package:app/models/model_card.dart';
import 'package:app/ui/card_details.dart';
import 'package:app/ui/card_listing.dart';
import 'package:flutter/material.dart';
import 'package:app/app_data.dart';
import 'package:app/models/end_point.dart';
import 'package:material_search/material_search.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;

  EndPoint ep;

  @override
  Widget build(BuildContext context) {
    this.ep=appData.getCurrEndPoint();

    String _selected;

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body:new Container(
        child: new MaterialSearch<String>(
          placeholder: 'Search', //placeholder of the search bar text input

          getResults:(String criteria)=>this.getResults(criteria),
          //sort: (String value, String criteria, String ) {return 0;},
          onSelect: (dynamic selected)=>this.onSelect(selected),
          onSubmit: (String value)=>this.onSubmit(value),

        ),
      ),
    );
  }

  void onSelect(dynamic selected) {
    String selectedID=selected.toString();
    var card=ep.cards.firstWhere((card)=>card.get(ep.id)==selectedID);

    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context){
            return new DetailPage(card);
        }
    ));
  }

  void onSubmit(String value) {
    print ('onSubmit');
  }

  _doSearch(String criteria) {
    var criteriaRE=new RegExp(r'' + criteria.toLowerCase().trim() + '');

    List<ModelCard> _cards=ep.cards;
    var foundCards=_cards.where((ModelCard card){
      return card.json.values.toList().toString().toLowerCase().contains(criteriaRE);
    });

    return foundCards.toList();
  }

  Future<List<MaterialSearchResult<dynamic>>> getResults(String criteria) async{
    if (criteria=='')
      return new List<MaterialSearchResult<String>>();

    List<ModelCard> resultsList  = _doSearch(criteria);
    List<MaterialSearchResult<String>> ret=new List<MaterialSearchResult<String>>();

    for (var i=0; i<resultsList.length; i++){
      var card=resultsList[i];
      ret.add(
          new MaterialSearchResult<String>(
            value: card.get(ep.id), //The value must be of type <String>
            text: card.get(ep.name), //String that will be show in the list
            icon: Icons.panorama_fish_eye,
          )
      );
    }

    return ret;
  }


}
