import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:magic_flutter/models/end_point.dart';


class AppData{
  HashMap<String, EndPoint> _endPoints=HashMap<String, EndPoint>();
  String _fixedEndPoint;

  EndPoint getEndPoint(String id) {
    if (_endPoints.length>0)
      return _endPoints[id];
    else {
      loadEndPoints();
      return _endPoints[id];
    }
  }
  EndPoint getCurrEndPoint(){
    if (_fixedEndPoint==null){
      loadEndPoints();
    }
    return getEndPoint(_fixedEndPoint);
  }
  void setCurrEndPoint(String id){
    _fixedEndPoint=id;
  }

  String _loadMagicEP(){/*
    {"name":"Adorable Kitten","manaCost":"{W}","cmc":1,"colors":["White"],"colorIdentity":["W"],"type":"Host Creature — Cat","types":["Host","Creature"],"subtypes":["Cat"],"rarity":"Common","set":"UST","setName":"Unstable","text":"When this creature enters the battlefield, roll a six-sided die. You gain life equal to the result.","artist":"Andrea Radeck","number":"1","power":"1","toughness":"1","layout":"normal","multiverseid":439390,"imageUrl":"http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=439390&type=card","rulings":[{"date":"2018-01-19","text":"Host creatures each have an ability that triggers when it enters the battlefield. It functions like any other creature."}],"printings":["UST"],"originalText":"When this creature enters the battlefield, roll a six-sided die. You gain life equal to the result.","originalType":"Host Creature — Cat","id":"95ebdf85f4ea74d584dfdfb72e3de5001d0748a9"}
    */
    var magic=EndPoint(endpointTitle:'Magic: The Gathering', endpointUrl:'https://api.magicthegathering.io/v1/cards', color:Colors.orange);
    magic.id='id'; magic.name='name';magic.text='text';
    magic.stats=['toughness', 'power', 'cmc'];
    magic.tags=['types', 'subtypes'];
    magic.fields=['artist', 'setName', 'watermark'];
    magic.related=null; //points to a different country by idField
    magic.images=['imageUrl'];
    magic.type='Bundled';
    _endPoints[magic.endpointTitle]=magic;

    return magic.endpointTitle;
  }
  String _loadCountriesEP(){/*
    {"name":"Spain","topLevelDomain":[".es"],"alpha2Code":"ES","alpha3Code":"ESP","callingCodes":["34"],"capital":"Madrid","altSpellings":["ES","Kingdom of Spain","Reino de España"],"region":"Europe","subregion":"Southern Europe","population":46438422,"latlng":[40.0,-4.0],"demonym":"Spanish","area":505992.0,"gini":34.7,"timezones":["UTC","UTC+01:00"],"borders":["AND","FRA","GIB","PRT","MAR"],"nativeName":"España","numericCode":"724","currencies":[{"code":"EUR","name":"Euro","symbol":"€"}],"languages":[{"iso639_1":"es","iso639_2":"spa","name":"Spanish","nativeName":"Español"}],"translations":{"de":"Spanien","es":"España","fr":"Espagne","ja":"スペイン","it":"Spagna","br":"Espanha","pt":"Espanha","nl":"Spanje","hr":"Španjolska","fa":"اسپانیا"},"flag":"https://restcountries.eu/data/esp.svg","regionalBlocs":[{"acronym":"EU","name":"European Union","otherAcronyms":[],"otherNames":[]}],"cioc":"ESP"}
    */
    var countries=EndPoint(endpointTitle:'Countries', endpointUrl:'https://restcountries.eu/rest/v2/all', color:Colors.indigo);
    countries.id='alpha3Code'; countries.name='name'; countries.text=null;
    countries.stats=['population', 'area'];
    countries.tags=['region', 'subregion'];
    countries.fields=['capital', 'currencies', 'topLevelDomain'];
    countries.related='borders'; //points to a different country by idField
    countries.images=['https://api.backendless.com/2F26DFBF-433C-51CC-FF56-830CEA93BF00/473FB5A9-D20E-8D3E-FF01-E93D9D780A00/files/CountryFlagsPng/{alpha3Code|lower}.png'];
    countries.type='Bundled';
    _endPoints[countries.endpointTitle]=countries;

    return countries.endpointTitle;
  }
  String _loadFightersEP(){/*
    Fighters http://ufc-data-api.ufc.com/api/v3/iphone/fighters
    {"id":241895,"nickname":null,"wins":20,"statid":1194,"losses":1,"last_name":"Cyborg","weight_class":"Women_Featherweight","title_holder":true,"draws":0,"first_name":"Cris","fighter_status":"Active","rank":"C","pound_for_pound_rank":"11","thumbnail":"http://imagec.ufc.com/http%253A%252F%252Fmedia.ufc.tv%252Fgenerated_images_sorted%252FFighter%252FCris-Cyborg%252FCris-Cyborg_241895_medium_thumbnail.jpg?w640-h320-tc1","belt_thumbnail":"http://imagec.ufc.com/http%253A%252F%252Fmedia.ufc.tv%252Ffighter_images%252FCris_Cyborg%252FCYBORG_CRIS_L-CHAMP-PRINT.png?w600-h600-tc1","left_full_body_image":"http://imagec.ufc.com/http%253A%252F%252Fmedia.ufc.tv%252Ffighter_images%252FCris_Cyborg%252FCYBORG_CRIS_L.png?mh530","right_full_body_image":"http://imagec.ufc.com/http%253A%252F%252Fmedia.ufc.tv%252Ffighter_images%252FCris_Cyborg%252FCYBORG_CRIS_L.png?mh530","profile_image":"http://imagec.ufc.com/http%253A%252F%252Fmedia.ufc.tv%252Ffighter_images%252FCris_Cyborg%252FCYBORG_CRIS.png?w600-h600-tc1","link":"http://www.ufc.com/fighter/Cris-Cyborg"},
    */
    var fighters=new EndPoint(endpointTitle:'UFC Fighters', endpointUrl:'http://ufc-data-api.ufc.com/api/v3/iphone/fighters', color:Colors.grey);
    fighters.id='id'; fighters.name='{nickname} {first_name} {last_name}'; fighters.text=null;
    fighters.stats=['wins', 'draws', 'losses'];
    fighters.tags=['fighter_status', 'rank'];
    fighters.fields=['link'];
    fighters.related=null; //points to a different country by idField;
    fighters.images=['profile_image','thumbnail','belt_thumbnail','left_full_body_image','right_full_body_image',];
    fighters.type='Bundled';
    _endPoints[fighters.endpointTitle]=fighters;

    return fighters.endpointTitle;
  }
  String _loadTrendingMoviesEP(){/*
    Movies https://api.themoviedb.org/3/trending/all/day?api_key=a2f45e3ad3af96b2ec9d0542adbfd1da&region=ES
    docs:  https://developers.themoviedb.org/3/movies/get-popular-movies

    "vote_count": 7639,
    "id": 299536,
    "video": false,
    "vote_average": 8.3,
    "title": "Avengers: Infinity War",
    "popularity": 246.214,
    "poster_path": "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", //"https://image.tmdb.org/t/p/w500/"+
    "original_language": "en",
    "original_title": "Avengers: Infinity War",
    "genre_ids": [12, 878, 14, 28],
    "backdrop_path": "/bOGkgRGdhrBYJSLpXaxhXVstddV.jpg",
    "adult": false,
    "overview": "As the Avengers and their allies have continued...",
    "release_date": "2018-04-25"
    */
    var trendingMovies=new EndPoint(
        endpointTitle:'Trending movies (TheMovieDB)',
        endpointUrl:'https://api.themoviedb.org/3/trending/all/day?api_key=a2f45e3ad3af96b2ec9d0542adbfd1da&region=ES',
        color:Colors.red);
    trendingMovies.id='id'; trendingMovies.name='original_title'; trendingMovies.text='overview';
    trendingMovies.stats=['vote_average', 'vote_count', 'popularity'];
    trendingMovies.tags=null;
    trendingMovies.fields=['release_date'];
    trendingMovies.related=null; //points to a different country by idField;
    trendingMovies.images=['https://image.tmdb.org/t/p/w500/{poster_path}','https://image.tmdb.org/t/p/w500/{backdrop_path}'];
    trendingMovies.type='Bundled';
    _endPoints[trendingMovies.endpointTitle]=trendingMovies;

    return trendingMovies.endpointTitle;
  }

  String _loadZomatoRestaurantsEP(){/*
    https://developers.zomato.com/api/v2.1/search?entity_id=280&entity_type=city
    > user-key: ab6e490707b8f2f51c864618f1ad90f4
    {
      "restaurant": {
        "R": { "res_id": 16769546 },
        "apikey": "ab6e490707b8f2f51c864618f1ad90f4",
        "id": "16769546",
        "name": "Katz's Delicatessen",
        "url": "https://www.zomato.com/new-york-city/katzs-delicatessen-lower-east-side?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1",
        "location": {
          "address": "205 East Houston Street, New York 10002",
          "locality": "Lower East Side",
          "city": "New York City",
          "city_id": 280,
          "latitude": "40.7223277778",
          "longitude": "-73.9873500000",
          "zipcode": "10002",
          "country_id": 216,
          "locality_verbose": "Lower East Side"
        },
        "switch_to_order_menu": 0,
        "cuisines": "Sandwich",
        "average_cost_for_two": 30,
        "price_range": 2,
        "currency": "$",
        "offers": [],
        "opentable_support": 0,
        "is_zomato_book_res": 0,
        "mezzo_provider": "OTHER",
        "is_book_form_web_view": 0,
        "book_form_web_view_url": "",
        "book_again_url": "",
        "thumb": "https://b.zmtcdn.com/data/res_imagery/16769546_RESTAURANT_2282b97610391948c11d1e6bd5057b04_c.jpg?fit=around%7C200%3A200&crop=200%3A200%3B%2A%2C%2A",
        "user_rating": {
          "aggregate_rating": "4.9",
          "rating_text": "Excellent",
          "rating_color": "3F7E00",
          "votes": "2457"
        },
        "photos_url": "https://www.zomato.com/new-york-city/katzs-delicatessen-lower-east-side/photos?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1#tabtop",
        "menu_url": "https://www.zomato.com/new-york-city/katzs-delicatessen-lower-east-side/menu?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1&openSwipeBox=menu&showMinimal=1#tabtop",
        "featured_image": "https://b.zmtcdn.com/data/res_imagery/16769546_RESTAURANT_2282b97610391948c11d1e6bd5057b04_c.jpg",
        "has_online_delivery": 0,
        "is_delivering_now": 0,
        "include_bogo_offers": true,
        "deeplink": "zomato://restaurant/16769546",
        "is_table_reservation_supported": 0,
        "has_table_booking": 0,
        "events_url": "https://www.zomato.com/new-york-city/katzs-delicatessen-lower-east-side/events#tabtop?utm_source=api_basic_user&utm_medium=api&utm_campaign=v2.1",
        "establishment_types": []
      }
    }
    */

    var zomato=new EndPoint(endpointTitle:'NY Restaurants (Zomato)', endpointUrl:'https://developers.zomato.com/api/v2.1/search?entity_id=280&entity_type=city', color:Colors.green);
    zomato.headers={"user-key": "ab6e490707b8f2f51c864618f1ad90f4"};
    zomato.id='{restaurant/id}'; zomato.name='{restaurant/name}'; zomato.text='{restaurant/location/address}\n{restaurant/location/locality}\n{restaurant/location/city}';
    zomato.stats=['{restaurant/user_rating/aggregate_rating}', '{restaurant/user_rating/votes}'];
    zomato.tags=['{restaurant/cuisines}'];
//    zomato.fields=['release_date'];
//    zomato.related=null; //points to a different country by idField;
    zomato.images=['{restaurant/featured_image}'];
    zomato.type='Bundled';
    _endPoints[zomato.endpointTitle]=zomato;

    return zomato.endpointTitle;
  }
  Future<HashMap<String, EndPoint>> loadEndPoints() async {
    //bundled APIs (from https://github.com/toddmotto/public-apis)

    var fixed;
    _loadMagicEP();
    _loadCountriesEP();
    _loadFightersEP();
    _loadTrendingMoviesEP();
    fixed=_loadZomatoRestaurantsEP();

    this._fixedEndPoint=fixed;


//    //load from storage: bundled APIs are overwritten by these
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    var temp=prefs.getString("api_endpoint");
//
//    if (temp!=null){
//      var jsondata=json.decode(temp);
//
//      List<dynamic>jsonep=jsondata['endPoints'];
//      for (var i=0; i<jsonep.length; i++){
//        var e=EndPoint.fromJson(jsonep[i]);
//        _endPoints[e.endpoint_title]=e;
//      }
//    }

    return _endPoints;
  }

  endPoints(){
    return _endPoints;
  }
  Map<String, dynamic> toJson() => {
    'endPoints': _endPoints.values.toList(),
  };

  Future<bool> save() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var json=jsonEncode(this.toJson());
    print ('about to save: $json');
    prefs.setString("api_endpoint", json );

    print ('save: done $json');
    return true;
  }

}
AppData appData=AppData();