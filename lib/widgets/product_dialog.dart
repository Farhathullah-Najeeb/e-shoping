import 'package:flutter/material.dart';
import 'dart:io'; // Used for File
import 'package:machine_test_farhathullah/models/fetch_all_products.dart'; // Ensure this path is correct
import 'package:machine_test_farhathullah/providers/product_provider.dart'; // Ensure this path is correct
import 'package:machine_test_farhathullah/common/custom_input_field.dart'; // Ensure this path is correct
import 'package:machine_test_farhathullah/common/loading_button.dart'; // Ensure this path is correct
import 'package:provider/provider.dart';

class ProductDialog extends StatefulWidget {
  final bool isEdit;
  final Product? product;

  const ProductDialog({super.key, required this.isEdit, this.product});

  @override
  ProductDialogState createState() => ProductDialogState();
}

class ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  late final TextEditingController _weightController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _depthController;
  late final TextEditingController _warrantyController;
  late final TextEditingController _shippingController;
  late final TextEditingController _availabilityController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.isEdit ? widget.product?.title : '',
    );
    _descriptionController = TextEditingController(
      text: widget.isEdit ? widget.product?.description : '',
    );
    _priceController = TextEditingController(
      text: widget.isEdit ? widget.product?.price.toString() : '',
    );
    _discountController = TextEditingController(
      text: widget.isEdit ? widget.product?.discountPercentage.toString() : '',
    );
    _stockController = TextEditingController(
      text: widget.isEdit ? widget.product?.stock.toString() : '',
    );
    _brandController = TextEditingController(
      text: widget.isEdit ? widget.product?.brand : '',
    );
    _skuController = TextEditingController(
      text: widget.isEdit ? widget.product?.sku : '',
    );
    _weightController = TextEditingController(
      text: widget.isEdit ? widget.product?.weight.toString() : '',
    );
    _widthController = TextEditingController(
      text: widget.isEdit ? widget.product?.dimensions.width.toString() : '',
    );
    _heightController = TextEditingController(
      text: widget.isEdit ? widget.product?.dimensions.height.toString() : '',
    );
    _depthController = TextEditingController(
      text: widget.isEdit ? widget.product?.dimensions.depth.toString() : '',
    );
    _warrantyController = TextEditingController(
      text: widget.isEdit ? widget.product?.warrantyInformation : '',
    );
    _shippingController = TextEditingController(
      text: widget.isEdit ? widget.product?.shippingInformation : '',
    );
    _availabilityController = TextEditingController(
      text: widget.isEdit ? widget.product?.availabilityStatus : '',
    );
    _minOrderController = TextEditingController(
      text: widget.isEdit
          ? widget.product?.minimumOrderQuantity.toString()
          : '',
    );
    _tagsController = TextEditingController(
      text: widget.isEdit ? widget.product?.tags.join(', ') : '',
    );

    // Initialize category and images in provider if editing
    final productProvider = context.read<ProductProvider>();
    if (widget.isEdit) {
      productProvider.setDialogCategory(widget.product?.category);
      // For existing products, if they have actual image URLs, you might want to fetch them
      // and display them. For this example, we assume new images replace old ones,
      // or you'd need logic to fetch existing product image URLs and map them to paths
      // or handle them differently if they are remote URLs vs local files.
      // For simplicity here, we clear existing selections when opening for edit.
      productProvider.clearDialogState(); // This will clear previous selection
      // If you want to show existing images, you'd need to convert URLs to File objects
      // or handle them separately. This example assumes you're only dealing with new local picks.
    } else {
      productProvider.clearDialogState(); // Clear state for new product
      productProvider.setDialogCategory(null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _weightController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _warrantyController.dispose();
    _shippingController.dispose();
    _availabilityController.dispose();
    _minOrderController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final bool isAddingUpdating = productProvider.isAddingUpdating;

    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Product' : 'Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information'),
              CustomInputField(
                controller: _titleController,
                labelText: 'Title',
                hintText: 'Enter product title',
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter product description',
                // maxLines: 3, // Allow multiple lines for description
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: productProvider.dialogSelectedCategory,
                hint: const Text('Select Category'),
                items: productProvider.categoryList
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: isAddingUpdating
                    ? null
                    : (value) => productProvider.setDialogCategory(value),
                validator: (value) =>
                    value == null ? 'Category is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _brandController,
                labelText: 'Brand',
                hintText: 'Enter brand (optional)',
              ),
              _buildSectionHeader('Pricing and Stock'),
              CustomInputField(
                controller: _priceController,
                labelText: 'Price',
                hintText: 'Enter price (e.g., 9.99)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Price is required';
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _discountController,
                labelText: 'Discount Percentage',
                hintText: 'Enter discount (e.g., 10.0)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Discount is required';
                  if (double.tryParse(value) == null ||
                      double.parse(value) < 0 ||
                      double.parse(value) > 100) {
                    return 'Enter a valid discount (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _stockController,
                labelText: 'Stock',
                hintText: 'Enter stock quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Stock is required';
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Enter a valid stock quantity';
                  }
                  return null;
                },
              ),
              _buildSectionHeader('Specifications'),
              CustomInputField(
                controller: _skuController,
                labelText: 'SKU',
                hintText: 'Enter SKU',
                validator: (value) => value!.isEmpty ? 'SKU is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _weightController,
                labelText: 'Weight (g)',
                hintText: 'Enter weight',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Weight is required';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align top for validators
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _widthController,
                      labelText: 'Width (cm)',
                      hintText: 'Width',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Valid width';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInputField(
                      controller: _heightController,
                      labelText: 'Height (cm)',
                      hintText: 'Height',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Valid height';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomInputField(
                      controller: _depthController,
                      labelText: 'Depth (cm)',
                      hintText: 'Depth',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Valid depth';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildSectionHeader('Additional Details'),
              CustomInputField(
                controller: _warrantyController,
                labelText: 'Warranty Information',
                hintText: 'Enter warranty details',
                validator: (value) =>
                    value!.isEmpty ? 'Warranty is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _shippingController,
                labelText: 'Shipping Information',
                hintText: 'Enter shipping details',
                validator: (value) =>
                    value!.isEmpty ? 'Shipping is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _availabilityController,
                labelText: 'Availability Status',
                hintText: 'e.g., In Stock',
                validator: (value) =>
                    value!.isEmpty ? 'Availability is required' : null,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _minOrderController,
                labelText: 'Minimum Order Quantity',
                hintText: 'Enter minimum order',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Minimum order quantity is required';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: _tagsController,
                labelText: 'Tags',
                hintText: 'Enter tags (comma-separated)',
                validator: (value) =>
                    value!.isEmpty ? 'At least one tag is required' : null,
              ),
              _buildSectionHeader('Images (Optional)'),
              // Thumbnail Image Section
              Text(
                'Thumbnail Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isAddingUpdating
                    ? null
                    : () async => await productProvider.pickThumbnail(),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: productProvider.isAddingUpdating
                          ? Colors.grey.shade400
                          : Theme.of(context).primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (productProvider.selectedThumbnailPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.file(
                            File(productProvider.selectedThumbnailPath!),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Thumbnail',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      if (productProvider.selectedThumbnailPath != null &&
                          !isAddingUpdating)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              productProvider.setThumbnailPath(null);
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red.shade400,
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Product Images Section
              Text(
                'Product Images',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: productProvider.selectedImagePaths.isEmpty
                    ? 0
                    : 100, // Adjust height if no images
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Show 3 images per row
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1, // Square images
                  ),
                  itemCount: productProvider.selectedImagePaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(productProvider.selectedImagePaths[index]),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (!isAddingUpdating)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                productProvider.removeImagePath(
                                  productProvider.selectedImagePaths[index],
                                );
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red.shade400,
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: isAddingUpdating
                      ? null
                      : () async => await productProvider.pickImages(),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Product Images'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isAddingUpdating
              ? null
              : () {
                  context.read<ProductProvider>().clearDialogState();
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        LoadingButton(
          onPressed: isAddingUpdating
              ? null
              : () async {
                  String? errorMessage;
                  if (!_formKey.currentState!.validate()) {
                    errorMessage = 'Please fill all required fields';
                  } else if (productProvider.dialogSelectedCategory == null) {
                    errorMessage = 'Please select a category';
                  }

                  if (errorMessage != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(errorMessage)));
                    return;
                  }

                  // Prepare product data
                  final productData = {
                    'id': widget.isEdit
                        ? widget.product!.id
                        : DateTime.now().millisecondsSinceEpoch % 1000000,
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'category': productProvider.dialogSelectedCategory!,
                    'price': double.parse(_priceController.text),
                    'discountPercentage': double.parse(
                      _discountController.text,
                    ),
                    'rating': widget.isEdit ? widget.product!.rating : 4.5,
                    'stock': int.parse(_stockController.text),
                    'tags': _tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty) // Filter out empty tags
                        .toList(),
                    'brand': _brandController.text.isEmpty
                        ? null
                        : _brandController.text,
                    'sku': _skuController.text,
                    'weight': int.parse(_weightController.text),
                    'dimensions': {
                      'width': double.parse(_widthController.text),
                      'height': double.parse(_heightController.text),
                      'depth': double.parse(_depthController.text),
                    },
                    'warrantyInformation': _warrantyController.text,
                    'shippingInformation': _shippingController.text,
                    'availabilityStatus': _availabilityController.text,
                    'reviews': widget.isEdit ? widget.product!.reviews : [],
                    'returnPolicy': widget.isEdit
                        ? widget.product!.returnPolicy
                        : '30 days return',
                    'minimumOrderQuantity': int.parse(_minOrderController.text),
                    'meta': widget.isEdit
                        ? widget.product!.meta.toJson()
                        : {
                            'createdAt': DateTime.now().toIso8601String(),
                            'updatedAt': DateTime.now().toIso8601String(),
                            'barcode':
                                'NEWBARCODE${DateTime.now().millisecondsSinceEpoch}',
                            'qrCode':
                                'NEWQRCODE${DateTime.now().millisecondsSinceEpoch}',
                          },
                    // For image URLs, in a real app, you'd upload these files
                    // to a server (e.g., Firebase Storage, AWS S3) and get their URLs.
                    // For this mock, we'll just ignore them in the productData payload,
                    // or you could add placeholder URLs if your mock API expects them.
                    'thumbnail': productProvider.selectedThumbnailPath != null
                        ? 'file://${productProvider.selectedThumbnailPath}' // Placeholder
                        : null,
                    'images': productProvider.selectedImagePaths.isNotEmpty
                        ? productProvider.selectedImagePaths
                              .map((path) => 'file://$path')
                              .toList() // Placeholder
                        : [],
                  };

                  try {
                    if (widget.isEdit) {
                      await productProvider.updateProduct(
                        widget.product!.id,
                        productData,
                      );
                    } else {
                      await productProvider.addProduct(productData);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Product ${widget.isEdit ? 'updated' : 'added'} successfully!',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print(
                      'Error ${widget.isEdit ? 'updating' : 'adding'} product: $e',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to ${widget.isEdit ? 'update' : 'add'}: $e',
                          ),
                        ),
                      );
                    }
                  }
                },
          isLoading: isAddingUpdating,
          text: widget.isEdit ? 'Update' : 'Add',
        ),
      ],
    );
  }
}
