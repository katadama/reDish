import 'package:flutter/material.dart';
import 'package:coo_list/data/models/profile_model.dart';

class ProfileAvatar extends StatelessWidget {
  final ProfileModel? profile;
  final String? initial;
  final Color? color;
  final double size;
  final VoidCallback? onTap;
  final bool isAddButton;

  const ProfileAvatar({
    super.key,
    this.profile,
    this.initial,
    this.color,
    this.size = 80.0,
    this.onTap,
    this.isAddButton = false,
  }) : assert(
          (profile != null) ||
              (initial != null && color != null) ||
              isAddButton,
          'Either provide a profile or both initial and color, or set isAddButton to true',
        );

  @override
  Widget build(BuildContext context) {
    final displayInitial =
        isAddButton ? '+' : profile?.initial ?? initial ?? '?';

    final displayColor = isAddButton
        ? Colors.grey.shade300
        : profile?.color ?? color ?? const Color(0xFFF34744);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            displayInitial,
            style: TextStyle(
              color: isAddButton || _isColorBright(displayColor)
                  ? Colors.black87
                  : Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool _isColorBright(Color color) {
    final brightness =
        (0.299 * (color.r * 255.0).round().clamp(0, 255) +
         0.587 * (color.g * 255.0).round().clamp(0, 255) +
         0.114 * (color.b * 255.0).round().clamp(0, 255)) / 255;
    return brightness > 0.6;
  }
}
