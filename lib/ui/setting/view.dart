import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' show Get, Inst, GetNavigation, ContextExtensionss;

import 'logic.dart';

class SettingPage extends StatelessWidget {
  final logic = Get.find<SettingLogic>();
  final state = Get.find<SettingLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            title: Text('settings.title'.tr()),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: kPrimaryColor, //change your color here
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'change_lang'.tr(),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          SizedBox(height: 15),
          Align(
            alignment: Alignment.center, // 核心：设置为水平居中
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (kIsWeb) return _buildWebLanguageSelector(context);

    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.white),
      child: ActionSlider.dual(
        backgroundBorderRadius: BorderRadius.circular(30.0),
        foregroundBorderRadius: BorderRadius.circular(30.0),
        width: context.width - 40.0,
        toggleColor: Colors.blue,
        backgroundColor: Colors.lightBlueAccent,
        startChild: Text(
          'lang_zh'.tr(),
          maxLines: 1,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
        endChild: Text(
          'lang_en'.tr(),
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Transform.rotate(
            angle: 0.5 * pi,
            child: const Icon(Icons.unfold_more_rounded, size: 28.0),
          ),
        ),
        startAction: (controller) async {
          if ("en_US" == logic.currentLang) {
            controller.loading(); //starts loading animation
            await Future.delayed(const Duration(seconds: 1));
            const locale = Locale('zh', 'CN');
            await _changeLocale(context, locale);
            controller.success(); //starts success animation
            await Future.delayed(const Duration(seconds: 1));
            controller.reset(); //resets the slider
          }
        },
        endAction: (controller) async {
          if ("zh_CN" == logic.currentLang) {
            controller.loading(); //starts loading animation
            await Future.delayed(const Duration(seconds: 1));
            const locale = Locale('en', 'US');
            await _changeLocale(context, locale);
            controller.success(); //starts success animation
            await Future.delayed(const Duration(seconds: 1));
            controller.reset(); //resets the slider
          }
        },
      ),
    );
  }

  Widget _buildWebLanguageSelector(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SizedBox(
        width: context.width - 40,
        child: SegmentedButton<String>(
          segments: [
            ButtonSegment<String>(value: 'zh', label: Text('lang_zh'.tr())),
            ButtonSegment<String>(value: 'en', label: Text('lang_en'.tr())),
          ],
          selected: {context.locale.languageCode},
          onSelectionChanged: (selection) async {
            final languageCode = selection.first;
            final locale = languageCode == 'en'
                ? const Locale('en', 'US')
                : const Locale('zh', 'CN');
            await _changeLocale(context, locale);
          },
        ),
      ),
    );
  }

  Future<void> _changeLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    Get.updateLocale(locale);
    logic.refreshCurrentLang(locale);
    logic.updateHomePage();
  }
}
