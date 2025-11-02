import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType textInputType;
  final String hintText;

  const TextFieldInput({
    super.key,
    required this.textInputType,
    required this.controller,
    this.isPassword = false,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      obscureText: isPassword,
      keyboardType: textInputType,
    );
  }
}
