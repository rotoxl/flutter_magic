import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class ImagePage extends StatelessWidget {
  final String url;

  const ImagePage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title:new Text(this.url) ),
      body:imageView(context)
    );
  }

  imageView(BuildContext context) {
    double screenHeight=MediaQuery.of(context).size.height - 120.0;
    return new Container(
        child: new PhotoView(
          size:Size.fromHeight(screenHeight),
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: 3.0,
        )
    );
  }


}
