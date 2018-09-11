import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class ImagePage extends StatelessWidget {
  final String url;

  const ImagePage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title:new Text(this.url) ),
      body:imageView()
    );
  }

  imageView() {
    return new Container(
        child: new PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewScaleBoundary.contained * 0.8,
          maxScale: 4.0,
        )
    );
  }


}
