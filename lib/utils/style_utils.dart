import 'package:flutter/material.dart';

class StyleUtils {
  static const Color textColorDark = Color(0xFF4A545A);
  static const Color primaryColor = Color(0xFFF34744);
  static const Color formTextColor = Color(0xFF4A545A);
  static const Color formBorderColor = Color(0xFFF2F3FA);
  static const Color formBackgroundColor = Colors.white;

  static const TextStyle listHeaderStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle categoryNameStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle itemCountStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: textColorDark,
    letterSpacing: 0.2,
  );

  static BorderRadius cardBorderRadius = BorderRadius.circular(16.0);

  static BoxShadow cardShadow = BoxShadow(
    color:
        Colors.black.withValues(alpha: 0.15),
    blurRadius: 0.1,
    spreadRadius: 0.5,
    offset: const Offset(0, 100),
  );

  static const double defaultPadding = 16.0;
  static const double cardSpacing = 8.0;

  static const double categoryImageSize = 74.0;

  static const TextStyle homeListHeaderStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle shoppingListHeaderStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle formFieldTextStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 16,
    color: formTextColor,
  );

  static const TextStyle formFieldLabelStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w400,
    color: formTextColor,
  );

  static InputDecoration getFormFieldDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: formFieldLabelStyle,
      prefixIcon: Icon(prefixIcon, color: primaryColor),
      filled: true,
      fillColor: formBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: formBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static ButtonStyle getPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      side: BorderSide(
        color: formBorderColor.withValues(alpha: 0.5),
        width: 2,
      ),
    );
  }

  static const TextStyle primaryButtonTextStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.white,
  );

  static const double loadingIndicatorSize = 20.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
  static Widget getLoadingIndicator() {
    return const SizedBox(
      height: loadingIndicatorSize,
      width: loadingIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: loadingIndicatorStrokeWidth,
        color: Colors.white,
      ),
    );
  }
}
