import 'package:flutter/material.dart';

InputDecoration registryInputDecoration({
  required String label,
  String? hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffixIcon,
    filled: true,
  );
}
