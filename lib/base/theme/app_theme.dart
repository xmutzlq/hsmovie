import 'package:ble_project/widget/search/searchbar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

///theme
const kPrimaryColor = Color(0xff212121);
const kPrimaryLightColor = Color(0xFF424242);
const primaryDarkColor = Color(0xff212121);
const secondaryColor = Color(0xFF9E9E9E);
const secondaryLightColor = Color(0xFF9E9E9E);
const secondaryDarkColor = Color(0xFF9E9E9E);
///bg
const commBgColor = Color(0xFFF5F5F5);
const searchBgColor = Color(0x579E9E9E);
///Shimmer
const shimmerColorLight = Color(0xFFEEEEEE);
const shimmerColorDark = Color(0xFFDDDDDD);

ThemeData get appThemeData => ThemeData(
    primaryColor: kPrimaryColor,
    primaryColorDark: primaryDarkColor,
    primaryColorLight: kPrimaryLightColor,
    scaffoldBackgroundColor: Colors.white,
    hintColor: kPrimaryColor,
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    textTheme: GoogleFonts.poppinsTextTheme());

AppBarTheme get appBarTheme => AppBarTheme();

TabBarThemeData get tabBarTheme => TabBarThemeData(
  labelColor: kPrimaryColor, dividerColor: Colors.transparent
);

AppBar get appBarHome => AppBar(
  title: _SearchBar(
    onTap: () => showSearch(context: Get.context!, delegate: SearchBarDelegate()),
  ),
  centerTitle: true,
  backgroundColor: commBgColor,
  elevation: 0.0,
  systemOverlayStyle: SystemUiOverlayStyle.dark,
);

class _SearchBar extends StatelessWidget {
  final Function() onTap;
  const _SearchBar({required this.onTap});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    debugPrint("SearchBar width : $width");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: searchBgColor,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search,
              color: kPrimaryColor,
            ),
            SizedBox(
              width: width - 100,
              child: Text(
                '搜索电影、电视剧、演员',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kPrimaryLightColor, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}