import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/core/models/product_model.dart';
import '../cubit/add_product_cubit.dart';
import '../cubit/add_product_state.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/image_picker_box.dart';
import '../widgets/section_title.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

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
  void initState() {
    super.initState();
    context.read<AddProductCubit>().fetchCategories();

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _descriptionController.text = widget.product!.description;
      _selectedCategoryId = widget.product!.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.product != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Product' : 'Add Product',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                onImagePicked: (file) {
                  setState(() {
                    _selectedImageFile = file;
                  });
                },
              ),
              if (isEditMode && _selectedImageFile == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    "Note: Keeping the current product image",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
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
                  return CategoryDropdown(
                    value: _selectedCategoryId,
                    categories: categories,
                    onChanged: (newValue) {
                      setState(() => _selectedCategoryId = newValue);
                    },
                    fillColor: inputColor,
                  );
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
                            if (value == null || value.isEmpty) return 'Required';
                            final price = double.tryParse(value);
                            if (price == null) return 'Invalid';
                            if (price <= 0) return 'Must be > 0';
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
                            if (value == null || value.isEmpty) return 'Required';
                            final qty = int.tryParse(value);
                            if (qty == null) return 'Invalid';
                            if (qty <= 0) return 'Must be > 0';
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
                hint: "Tell buyers about your product...",
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
                  SnackBar(content: Text(isEditMode ? 'Product updated successfully!' : 'Product added successfully!')),
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
                return const SizedBox(height: 55, child: Center(child: CircularProgressIndicator()));
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!isEditMode && _selectedImageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a product image'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    if (_selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a category')),
                      );
                      return;
                    }

                    if (isEditMode) {
                      context.read<AddProductCubit>().updateProduct(
                        productId: widget.product!.id,
                        name: _nameController.text,
                        categoryId: _selectedCategoryId!,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        quantity: int.tryParse(_quantityController.text) ?? 0,
                        description: _descriptionController.text,
                        imageFile: _selectedImageFile,
                        existingImageUrl: widget.product!.imageUrl,
                        existingCreatedAt: widget.product!.createdAt,
                      );
                    } else {
                      context.read<AddProductCubit>().saveProduct(
                        name: _nameController.text,
                        categoryId: _selectedCategoryId!,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        quantity: int.tryParse(_quantityController.text) ?? 0,
                        description: _descriptionController.text,
                        imageFile: _selectedImageFile,
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isEditMode ? 'Update Product' : 'Save Product',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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