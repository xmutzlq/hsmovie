
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zo_animated_border/widget/zo_dual_border.dart';
import 'package:zo_animated_border/widget/zo_snake_border.dart';

class PersonalInfoEditPage extends GetView<PersonalLogic> {

  PersonalInfoEditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: const Text('编辑'),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: kPrimaryColor, //change your color here
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.save_rounded,
                  color: kPrimaryColor, // Here
                ),
                onPressed: () async {
                  try {
                    await controller.saveNicknameAndAvatarSvgToDB();
                    ToastUtil.showToast('保存成功');
                    Get.back();
                  } on Exception catch (e) {
                    ToastUtil.showToast('保存失败 : ${e.toString()}');
                  }
                },
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          Expanded(child: _buildContent())
        ]
      )
    );
  }

  Widget _buildContent() {
    return ScrollConfiguration(
        behavior: MyScrollBehavior(),
        child: SingleChildScrollView(
          controller: controller.personState.scrollController,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                _buildNicknameForm(),
                _buildAvatarChoiceForm(),
                const SizedBox(height: 40),
                _buildExchangeAvatarButton()
              ],
            ),
          ),
        )
    );
  }

  Widget _buildNicknameForm() {
    final _formKey = GlobalKey<FormBuilderState>();
    return FormBuilder(
      key: _formKey,
      child:  FormBuilderTextField(
        name: 'nickname',
        decoration: InputDecoration(
          labelText: '昵称',
          suffix: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _formKey.currentState!.fields['nickname']?.reset();
            },
          ),
        ),
        maxLines: 1,
        maxLength: 15,
        onChanged: (val) {
          controller.updateNickNameValue(val);
        },
      ),
    );
  }

  Widget _buildAvatarChoiceForm() {
    controller.getRandomAvatars();
    return controller.obx((state) => _buildAvatarGrid(state!),
      onLoading: _buildAvatarGridBone(),
      onEmpty: const Text('No data found'),
      onError: (error) => Text(error ?? 'unknow'),
    );
  }

  Widget _buildAvatarGrid(List<String> avatars) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        return GetBuilder<PersonalLogic>(
          id: 'item_$index', // 关键：为每个item指定唯一ID
          builder: (controller) {
            final state = controller.personState.avatarItemStatus[index]!;
            return _buildAnimateAvatar(index, state.avatar, state.isSelected);
          }
        );
      },
    );
  }

  /// 带动画的selected状态
  Widget _buildAnimateAvatar(int index, String avatarSvgStr, bool isSelected) {
    return isSelected ? ZoDualBorder(
      glowOpacity: 0.4,
      firstBorderColor: Colors.yellow,
      secondBorderColor: Colors.orange,
      trackBorderColor: Colors.transparent,
      borderWidth: 2,
      borderRadius: BorderRadius.circular(10),
      child: _buildClickAvatar(index, avatarSvgStr),
    ) : _buildClickAvatar(index, avatarSvgStr);
  }

  Widget _buildClickAvatar(int index, String avatarSvgStr) {
    return InkWell(child:_buildAvatar(avatarSvgStr), onTap: () => {
      controller.singleAvatarSelected(index)
    });
  }

  Widget _buildAvatar(String avatarSvgStr) {
    return SvgPicture.string(avatarSvgStr, width: 35, height: 35);
  }

  Widget _buildExchangeAvatarButton() {
    return InkWell(
      onTap: () => controller.getRandomAvatars(),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: ZoSnakeBorder(
        glowOpacity: 0,
        snakeHeadColor: Colors.red,
        snakeTailColor: Colors.blue,
        snakeTrackColor: Colors.blueGrey,
        borderWidth: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 150,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "换一批",
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      )
    );
  }

  /// 骨架Loading
  Widget _buildAvatarGridBone() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return _buildBone();
      },
    );
  }

  Widget _buildBone() {
    return SizedBox(
      width: 35.0,
      height: 35.0,
      child: Shimmer.fromColors(
        baseColor: shimmerColorDark,
        highlightColor: shimmerColorLight,
        child: Container(
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
            color: controller.randomColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}