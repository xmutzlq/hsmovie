import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';

class MovieListView extends StatefulWidget {
  final List<VodInfo> items;
  final Function(int movieId)? onItemInteraction;

  MovieListView({Key? key, required this.items, this.onItemInteraction})
      : super(key: key);

  @override
  State createState() => _MovieListViewState();
}

class _MovieListViewState extends State<MovieListView> {
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
        return Container(padding: const EdgeInsets.all(20.0), child: const Center(child: SizedBox()));
      },
    );
  }

  Widget _buildContent(
      AsyncSnapshot<List<VodInfo>> snapshot, BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: width / 1.75,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      child: SizeCacheWidget(
        // estimateCount: snapshot.data!.length,
        child: ListView.builder(
          cacheExtent: 500,
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.length > 10 ? 10 : snapshot.data!.length,
          itemBuilder: (BuildContext context, int index) =>
            FrameSeparateWidget(
              index: index,
              placeHolder: Container(
                height: width / 4 / 2,
              ),
              child: InkWell(
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
                  index == 0)
              ),
            )
          )
      )
    );
  }

  _buildItem(String name, String imagePath, String backdropPath,
      double itemHeight, bool isFirst) {
    return Column(
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 10.0,
            margin: EdgeInsets.only(left: isFirst ? 20 : 10, right: 10, bottom: 15),
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            child: Image(
              image: CachedNetworkImageProvider(imagePath),
              fit: BoxFit.cover,
              width: itemHeight * 4 / 3,
              height: itemHeight / 2,
            ),
          )
        ),
        Text(
          name.length > 8 ? name.substring(0, 8) : name,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 13),
        )
      ],
    );
  }
}
