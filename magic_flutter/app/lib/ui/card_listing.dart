import 'package:app/app_data.dart';
import 'package:app/ui/search_page.dart';
import 'package:flutter/material.dart';
import 'package:app/models/end_point.dart';
import 'package:app/models/model_card.dart';
import 'package:app/ui/about_api_page.dart';
import 'package:app/ui/card_details.dart';

enum Mode { list, grid }
enum MenuItems {search, toggleGridList, about}

class CardListing extends StatefulWidget {
  double offset = 0.0;

  void Function(AppData p) _themeUpdater;

  CardListing(void Function(AppData p) this._themeUpdater);

  double getOffsetMethod() {
    return offset;
  }
  void setOffsetMethod(double val) {
    offset=val;
  }

  @override
  _CardListingState createState() => new _CardListingState(Mode.grid);
}

class _CardListingState extends State<CardListing> {

  GlobalKey<ScaffoldState> _scaffoldKey;

  EndPoint ep;
  Mode mode;
  bool modeChangedAtRunTime = false;

  ScrollController _scrollController;

  List<ModelCard> selectedCards=new List<ModelCard>();

  _CardListingState(this.mode);

  EndPoint getEndPoint(){
    return appData.getCurrEndPoint();
  }
  List<ModelCard> epCards(){
    if (getEndPoint().cards!=null && getEndPoint().cards.length>0){
      return getEndPoint().cards;
    } else {
      //
      var cardsToRecycle=null;
      //If same url has already being downloaded in another, related, endpoint --> lets recycle it
      appData.endPoints().forEach((String key, EndPoint value){
        if (value.endpointUrl==ep.endpointUrl){
          if (value.cards!=null && value.cards.length>0){
            print ('recycled!');
            cardsToRecycle=value.cards;
          }
        }
      });
      if (cardsToRecycle!=null)
        return cardsToRecycle;
      else
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController(
        initialScrollOffset: widget.getOffsetMethod(),
        keepScrollOffset: true,
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._scaffoldKey = new GlobalKey<ScaffoldState>();
    ep = getEndPoint();

    return new Scaffold(
      key: this._scaffoldKey,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  _buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text(ep.endpointTitle),

        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.settings), onPressed:_navigateConfig,),
          //new IconButton(icon: const Icon(Icons.search), onPressed: _handleSearch, tooltip: 'Search',),

          new PopupMenuButton<MenuItems>(
            onSelected: (MenuItems value) { _handleMenuTap(context, value); },

            itemBuilder: (BuildContext context) => <PopupMenuItem<MenuItems>>[

              new PopupMenuItem<MenuItems>(value: MenuItems.search, child: const Text('Search in results'),),
              new PopupMenuItem<MenuItems>(value: MenuItems.toggleGridList, child: const Text('Toggle list/grid mode'),),
//              new PopupMenuDivider<MenuItems>(),
              new PopupMenuItem<MenuItems>(value: MenuItems.about, child: const Text('About this API'),),

            ],
          ),
    ]);
  }
  _handleSearch(){
    if (epCards().length>0){
      Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context){return new SearchPage();}
      ));
    }
  }
  _navigateConfig(){
    Navigator.pushNamed(context, '/config');
  }
  _handleMenuTap(BuildContext context, MenuItems value) {
      switch (value) {
        case MenuItems.toggleGridList:
          appData.logEvent('listing_toggleGridList', {'ep':ep.endpointTitle});
          setState(() {
            if (this.mode == Mode.list)
              this.mode = Mode.grid;
            else
              this.mode = Mode.list;

            modeChangedAtRunTime = true;
          });
          break;

        case MenuItems.about:
          new AboutAPIPage(this.ep).customDialogShow(context);
          break;

        case MenuItems.search:
          _handleSearch();
          break;
      }
  }

  _buildBody(BuildContext context) {
    appData.logEvent('listing_show', {'ep':ep.endpointTitle, 'typeOfListing':ep.typeOfListing.toString()} );

    var _cards=epCards();

    var setThemeIn10ms=(){
      if (this.ep.theme!=null && appData.themeApplied==this.ep.theme)
        return;
      else if (this.ep.color!=null && appData.themeApplied==this.ep.color)
        return;

      new Future.delayed(const Duration(milliseconds: 10), (){
        if (widget._themeUpdater!=null)
          widget._themeUpdater(appData); //forzamos tema
      });
    };

    if (_cards.length > 0) {
      setThemeIn10ms();

      return _buildGridOrList(context);
    } else {
      var ep=getEndPoint();

      return FutureBuilder<List<ModelCard>>(
          future: fetchPost(ep),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              ep.cards = snapshot.data;
//              return _buildGridOrList(context);

              setThemeIn10ms();

              return Center(child: CircularProgressIndicator());

            } else if (snapshot.hasError) {
              return _emptyState(snapshot.error);
            }

            // By default, show a loading spinner
            return Center(child: CircularProgressIndicator());
          });
    }
  }

  _buildGridOrList(BuildContext context) {
    if (this.mode == Mode.list)
      return _buildList(context);
    else
      return _buildGrid(context);
  }

  _buildList(BuildContext context) {
    var _cards=epCards();

    //prueba, a ver si lo coge
    _scrollController = new ScrollController(
      initialScrollOffset: widget.getOffsetMethod(),
      keepScrollOffset: true,
    );

    return new NotificationListener(
      child:ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: (_cards.length * 2) - 1,
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index.isOdd)
            return Divider();
          else
            return _buildRow(_cards[index ~/ 2], context);
        }
      ),
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          widget.setOffsetMethod(notification.metrics.pixels);
        }
      },
    );
  }
  _buildRow(ModelCard card, BuildContext context) {
    var txt=card.get(this.ep.name);
    if (txt==null){
      txt="Not found: ${this.ep.name}";
    }

    return ListTile(
      title: Text(txt, style: Theme.of(context).textTheme.title,),
      trailing: Icon(
        Icons.panorama_fish_eye,
        color: Theme.of(context).primaryColor,
      ),
      onTap: () {
//        Scaffold.of(context).showSnackBar(SnackBar(content:Text(card.name)));

        _navigateDetailPage(card, context);
      },
    );
  }

  _buildGrid(BuildContext context) {
    var _cards=epCards();

    double verticalMargin=0.0, horizontalMargin=0.0;
    if (this.ep.typeOfListing==TypeOfListing.gridWithoutName){
      verticalMargin=10.0;
      horizontalMargin=3.0;
    }

    //prueba, a ver si lo coge
    _scrollController = new ScrollController(
      initialScrollOffset: widget.getOffsetMethod(),
      keepScrollOffset: true,
    );

    return new OrientationBuilder(
        builder: (context, orientation) {
          return new NotificationListener(child:new GridView.count(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
              mainAxisSpacing: verticalMargin,
              childAspectRatio: 1.1,
              crossAxisCount: (orientation == Orientation.portrait ? 2 : 3),
              children: List.generate(_cards.length, (index) {
                return _buildGridItem(_cards[index], context);
              })
          ),
          onNotification: (notification) {
            if (notification is ScrollNotification) {
              widget.setOffsetMethod(notification.metrics.pixels);
            }
          }
          );
        }
    );
  }
  _buildGridItem(ModelCard card, BuildContext context) {
    var fi=card.get(this.ep.firstImage());
    var src=(fi!=null?fi:card.getImgPlaceholder());

    var textStyle=Theme.of(context).textTheme.body1.copyWith(color: Colors.white);

    var txt=card.get(this.ep.name);
    if (txt==null){
      txt="Not found: ${this.ep.name}";
    }

    Widget domcard, domImg, domTxt;

    var isSelected=this.selectedCards.contains(card);

    if (this.ep.typeOfListing==TypeOfListing.gridWithName) {
      domImg = Image.network(src, fit: BoxFit.cover);

      domTxt = Container(
          height: 30.0,
          padding: EdgeInsets.only(top: 5.0),
          decoration: new BoxDecoration(color: Colors.black54),
          child: new Text(txt, style: textStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,),
      );

      domcard=new Container(
        color:isSelected?Theme.of(context).selectedRowColor:null,
        child:new GridTile(
          child: domImg,
          footer:domTxt
        )
      );

    } else if (this.ep.typeOfListing==TypeOfListing.gridWithoutName) {

      domImg = Image.network(src, fit: BoxFit.fitHeight);

      domcard=new Container(
        color:isSelected?Theme.of(context).accentColor:null,
        child:new GridTile(child: domImg,),
      );
    }

    return new GestureDetector(
      child:domcard,
      onTap: () {
        if (this.ep.typeOfDetail==TypeOfDetail.productCompare)
          _toggleSelection(card, context);
        else
          _navigateDetailPage(card, context);
      },
    );

  }
  _toggleSelection(ModelCard card, BuildContext context){
    var newSelectedCards=this.selectedCards.sublist(0);

    if (newSelectedCards.contains(card)){
      newSelectedCards.remove(card);
    } else{
      newSelectedCards.add(card);
    }

    if (newSelectedCards.length>=2){
      this.selectedCards.clear();
      _navigateDetailPage(newSelectedCards[0], context, cardToCompare: card,);
    } else {
      setState(() {this.selectedCards=newSelectedCards;});
    }
  }
  _navigateDetailPage(ModelCard card, BuildContext context, {ModelCard cardToCompare}) async {
//    Navigator.pushNamed(context, '/detail');//no se puede usar pushNamed porque no recibe ningún otro parámetro

    Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context){
        if (ep.typeOfDetail==TypeOfDetail.productCompare){

          return new DetailPage.compare(card, cardToCompare);

        } else {
          return new DetailPage(card);

        }
      }
    ));
  }

  _emptyState(err){
    var tt=Theme.of(context).textTheme;

    var title='Unable to connect';
    var subtitle="Maybe it's not you but we can't found the resource. Tap to try again.";

    if (err.toString().contains('SocketException')){
      return new GestureDetector(
        onTap: (){
          setState((){/*retry connection*/});
        },
        child:new Column(
          children: <Widget>[
              SizedBox(height: 100.0),
              new Icon(Icons.cloud_off, color:Colors.black45, size: 90.0),

              Text(title, style:tt.title),
              SizedBox(height: 10.0),

              new Container(padding:EdgeInsets.symmetric(horizontal: 16.0),
                  child:Text(subtitle, style:tt.subhead, textAlign: TextAlign.center,)
              )
          ],)
      );
    }
  }
  void _showSnackbar(String text) {
    final snackBar =
        SnackBar(content: Text(text), duration: Duration(seconds: 3));
    if (this._scaffoldKey != null && this._scaffoldKey.currentState != null)
      this._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
