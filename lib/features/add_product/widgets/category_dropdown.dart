import 'package:flutter/material.dart';
import 'package:marketplace_app/core/models/category_model.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value;
  final List<CategoryModel> categories;
  final ValueChanged<String?> onChanged;
  final Color fillColor;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Select category', style: TextStyle(color: Colors.grey, fontSize: 14)),
          dropdownColor: fillColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          items:categories.map((CategoryModel category) {
            return DropdownMenuItem(value: category.id, child: Text(category.name));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}