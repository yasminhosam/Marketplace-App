import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/add_product_cubit.dart';
import '../cubit/add_product_state.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/image_picker_box.dart';
import '../widgets/section_title.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  File? _selectedImageFile;

  final Color bgColor = const Color(0xFF13161E);
  final Color inputColor = const Color(0xFF1E212B);
  final Color primaryBlue = const Color(0xFF1A65FF);

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    context.read<AddProductCubit>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Product Image'),
              const SizedBox(height: 12),
              ImagePickerBox(
                isPrimary: true,
                inputColor: inputColor,
                primaryColor: primaryBlue,
                selectedImage: _selectedImageFile,
                onImagePicked: (file){
                  setState(() {
                    _selectedImageFile=file;
                  });
                },
              ),
              const SizedBox(height: 24),

              const SectionTitle(title: 'Product Name'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hint: 'e.g. Vintage Blue Denim Jacket',
                fillColor: inputColor,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const SectionTitle(title: 'Category'),
              const SizedBox(height: 8),
              BlocBuilder<AddProductCubit, AddProductState>(
                builder: (context, state) {
                  final categories = context.read<AddProductCubit>().cachedCategories;

                  if (categories.isEmpty && state is AddProductCategoriesLoading) {
                    return const CircularProgressIndicator();
                  }

                  if (categories.isEmpty && state is AddProductCategoriesFailure) {
                    return Text(
                      (state).errorMessage,
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  if (categories.isNotEmpty) {
                    return CategoryDropdown(
                      value: _selectedCategoryId,
                      categories: categories,
                      onChanged: (newValue) {
                        setState(() => _selectedCategoryId = newValue);
                      },
                      fillColor: inputColor,
                    );
                  }

                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Price (\$)'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _priceController,
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                          fillColor: inputColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Price is required';
                            if (double.tryParse(value) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Stock Quantity'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _quantityController,
                          hint: '1',
                          keyboardType: TextInputType.number,
                          fillColor: inputColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Quantity required';
                            if (int.tryParse(value) == null) return 'Enter a whole number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle(title: 'Description'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hint: "Tell buyers about your product's\ncondition, size, and unique features...",
                maxLines: 4,
                fillColor: inputColor,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocConsumer<AddProductCubit, AddProductState>(
            listener: (context, state) {
              if (state is AddProductSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added successfully!')),
                );
                Navigator.pop(context);
              } else if (state is AddProductFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              if (state is AddProductLoading) {
                return const SizedBox(
                  height: 55,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {

                  if (_formKey.currentState!.validate()) {

                    if (_selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a category')),
                      );
                      return;
                    }


                    context.read<AddProductCubit>().saveProduct(
                      name: _nameController.text,
                      categoryId: _selectedCategoryId!,
                      price: double.tryParse(_priceController.text) ?? 0.0,
                      quantity: int.tryParse(_quantityController.text) ?? 0,
                      description: _descriptionController.text,
                      imageFile: _selectedImageFile,
                    );
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Save Product', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}