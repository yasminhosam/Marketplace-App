import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBox extends StatelessWidget {
  final bool isPrimary;
  final Color inputColor;
  final Color primaryColor;
  final File? selectedImage;
  final ValueChanged<File>? onImagePicked;
  final bool hasError ;

  const ImagePickerBox({
    super.key,
    this.isPrimary = false,
    required this.inputColor,
    required this.primaryColor,
    this.selectedImage,
    this.onImagePicked,
    this.hasError=false
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && onImagePicked != null) {
      onImagePicked!(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(16),
          border: hasError
              ? Border.all(color: Colors.redAccent, width: 2)
              : isPrimary
              ? Border.all(color: primaryColor.withOpacity(0.5), width: 2)
              : null,
        ),
        child: selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(selectedImage!, fit: BoxFit.cover),
        )
            : Center(
          child: Icon(
            isPrimary ? Icons.camera_alt : Icons.image,
            color: hasError
                ? Colors.redAccent
                : (isPrimary ? primaryColor : Colors.grey),
            size: 28,
          ),
        ),
      ),
    );
  }
}