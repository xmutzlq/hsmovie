import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GuessLikeListView extends StatefulWidget {
  final List<VodInfo> items;
  final Function(int movieId)? onItemInteraction;

  GuessLikeListView({Key? key, required this.items, this.onItemInteraction}) : super(key: key);

  @override
  State createState() => _MovieListViewState();
}

class _MovieListViewState extends State<GuessLikeListView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.value(widget.items),
      builder: (context, AsyncSnapshot<List<VodInfo>> snapshot) {
        if (snapshot.hasData) {
          return _buildContent(snapshot, context);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Container(
            padding: EdgeInsets.all(10.0),
            child: Center(child: SizedBox()));
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<List<VodInfo>> snapshot, BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      height: width / 2 - 20,
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
        cacheExtent: 500,
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.data!.length > 10 ? 10 : snapshot.data!.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () => {
              if (widget.onItemInteraction != null) {
                widget.onItemInteraction!(snapshot.data![index].vodID)
              } else {
                debugPrint("No handle")
              }
            },
            child: _buildItem(
                snapshot.data![index].vodName,
                snapshot.data![index].vodPic,
                snapshot.data![index].vodPic,
                width / 4,
                index, snapshot.data!.length)
          );
        },
      ),
    );
  }

  _buildItem(String name, String imagePath, String backdropPath, double itemHeight, int index, int length) {
    return Column(
      children: [
        Expanded(child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 10.0,
          margin: EdgeInsets.only(left: index == 0 ? 10 : 5, right: index == length - 1 ? 10 : 5, bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Image(image: CachedNetworkImageProvider(imagePath),
            fit: BoxFit.cover,
            width: itemHeight,
            height: itemHeight,),
        )),
        Text(
          name.length > 8 ? name.substring(0, 8) : name,
          maxLines: 2,
          overflow: TextOverflow.clip,
          style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.bold, fontSize: 13),
        )
      ],
    );
  }

}