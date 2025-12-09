// 状态数据类
class AvatarItemState {
  final bool isSelected;
  final String avatar;

  AvatarItemState({
    required this.isSelected,
    required this.avatar,
  });

  AvatarItemState copyWith({
    required bool isSelected,
    String? avatar
  }) {
    return AvatarItemState(
      isSelected: isSelected,
      avatar: avatar ?? this.avatar
    );
  }
}