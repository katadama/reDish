import 'package:flutter/material.dart';
import 'package:coo_list/utils/style_utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: StyleUtils.formFieldTextStyle,
      decoration: StyleUtils.getFormFieldDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
      ),
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
    );
  }
}
