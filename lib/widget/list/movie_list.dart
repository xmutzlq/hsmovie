import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';

class MovieListView extends StatefulWidget {
  final double leftPaddingControl;
  final List<VodInfo> items;
  final Function(int movieId)? onItemInteraction;

  MovieListView({
    Key? key,
    required this.items,
    this.onItemInteraction,
    this.leftPaddingControl = 0,
  }) : super(key: key);

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
          return _buildContent(snapshot, context, widget.leftPaddingControl);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: const Center(child: SizedBox()),
        );
      },
    );
  }

  Widget _buildContent(
    AsyncSnapshot<List<VodInfo>> snapshot,
    BuildContext context,
    double leftPaddingControl,
  ) {
    final width = MediaQuery.of(context).size.width;
    final layoutWidth = kIsWeb && width > 480 ? 480.0 : width;
    final itemCount = snapshot.data!.length > 10 ? 10 : snapshot.data!.length;
    final itemHeight = layoutWidth / 4;
    final contentWidth = itemCount * (itemHeight * 4 / 3 + 20);
    final distributeAcrossRow = kIsWeb && contentWidth <= width;
    return Container(
      height: layoutWidth / 1.75,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      child: SizeCacheWidget(
        // estimateCount: snapshot.data!.length,
        child: distributeAcrossRow
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  itemCount,
                  (index) => _buildInteractiveItem(
                    snapshot.data![index],
                    itemHeight,
                    isFirst: false,
                    leftPaddingControl: 0,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                cacheExtent: 500,
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) =>
                    FrameSeparateWidget(
                      index: index,
                      placeHolder: Container(height: itemHeight / 2),
                      child: _buildInteractiveItem(
                        snapshot.data![index],
                        itemHeight,
                        isFirst: index == 0,
                        leftPaddingControl: leftPaddingControl,
                      ),
                    ),
              ),
      ),
    );
  }

  Widget _buildInteractiveItem(
    VodInfo item,
    double itemHeight, {
    required bool isFirst,
    required double leftPaddingControl,
  }) {
    return InkWell(
      onTap: () {
        if (widget.onItemInteraction != null) {
          widget.onItemInteraction!(item.vodID);
        } else {
          debugPrint('No handle');
        }
      },
      child: _buildItem(
        item.vodName,
        item.vodPic,
        item.vodPic,
        itemHeight,
        isFirst,
        leftPaddingControl,
      ),
    );
  }

  _buildItem(
    String name,
    String imagePath,
    String backdropPath,
    double itemHeight,
    bool isFirst,
    double leftPaddingControl,
  ) {
    return Column(
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 10.0,
            margin: EdgeInsets.only(
              left: (isFirst ? 20 : 10) + leftPaddingControl,
              right: 10,
              bottom: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Image(
              image: CachedNetworkImageProvider(imagePath),
              fit: BoxFit.cover,
              width: itemHeight * 4 / 3,
              height: itemHeight / 2,
            ),
          ),
        ),
        Text(
          name.length > 8 ? name.substring(0, 8) : name,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
