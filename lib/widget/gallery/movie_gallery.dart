import 'package:ble_project/model/vod_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MovieGallery extends StatefulWidget {

  final List<VodInfo> items;

  const MovieGallery({Key? key, required this.items}) : super(key: key);

  @override
  _MovieGalleryState createState() => _MovieGalleryState();
}

class _MovieGalleryState extends State<MovieGallery> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.value(widget.items),
      builder: (context, AsyncSnapshot<List<VodInfo>> snapshot) {
        if (snapshot.hasData) {
          return buildContent(snapshot, context);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildContent(AsyncSnapshot<List<VodInfo>> snapshot, BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      height: width / 3,
      margin: EdgeInsets.only(bottom: 50, top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data!.length > 10 ? 10 : snapshot.data!.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(snapshot.data![index].vodPic, width / 3, index == 0);
        },
      ),
    );
  }

  _buildItem(String imagePath, double itemHeight, bool isFirst) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 10.0,
      margin: EdgeInsets.only(left: isFirst ? 0 : 10, right: 10, bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Image(
        image: CachedNetworkImageProvider(imagePath),
        fit: BoxFit.cover,
        width: itemHeight * 4 / 3,
        height: itemHeight / 2,),
    );
  }

}