import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChange;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChange,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchField();
}

class _CustomSearchField extends State<CustomSearchField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChange,

      style: TextStyle(color: AppColors.mainTextColor),
      decoration: InputDecoration(
        hint: Text(
          widget.hint,
          style: TextStyle(color: AppColors.subTextColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        filled: true,
        fillColor: AppColors.itemsColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.mainTextColor.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.cyanColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.redColor),
        ),
        prefixIcon: Icon(Icons.search, color: AppColors.subTextColor, size: 20),
      ),
    );
  }
}
