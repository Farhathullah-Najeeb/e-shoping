import 'package:flutter/material.dart';
import 'package:machine_test_farhathullah/providers/product_provider.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/product_dialog.dart';
import 'package:machine_test_farhathullah/screens/product_detail_screen/product_detail_widgets/error_view.dart';
import 'package:machine_test_farhathullah/screens/product_detail_screen/product_detail_widgets/product_detail_app_bar.dart';
import 'package:machine_test_farhathullah/screens/product_detail_screen/product_detail_widgets/product_details.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int? productId = ModalRoute.of(context)?.settings.arguments as int?;
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    if (productId != null &&
        !productProvider.isLoadingProductDetail &&
        (productProvider.selectedProduct == null ||
            productProvider.selectedProduct!.id != productId)) {
      productProvider.fetchProductById(productId);
    }

    if (productId == null) {
      return const Scaffold(
        appBar: ProductDetailAppBar(title: 'Product Details'),
        body: Center(child: Text('Product ID not provided.')),
      );
    }

    return Consumer<ProductProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: ProductDetailAppBar(
          title: provider.selectedProduct?.title ?? 'Product Details',
          product: provider.selectedProduct,
          isAddingUpdating: provider.isAddingUpdating,
          onEdit:
              provider.selectedProduct != null &&
                  provider.selectedProduct!.isDeleted != true
              ? () {
                  provider.setDialogCategory(
                    provider.selectedProduct!.category,
                  );
                  provider.setThumbnailPath(
                    provider.selectedProduct!.thumbnail,
                  );
                  provider.setImagePaths(provider.selectedProduct!.images);
                  showDialog(
                    context: context,
                    builder: (dialogContext) => ProductDialog(
                      isEdit: true,
                      product: provider.selectedProduct,
                    ),
                  );
                }
              : null,
          onDelete:
              provider.selectedProduct != null &&
                  provider.selectedProduct!.isDeleted != true
              ? () async {
                  final confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text(
                        'Are you sure you want to delete "${provider.selectedProduct!.title}"?',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                        ),
                      ],
                    ),
                  );

                  if (confirmDelete == true) {
                    try {
                      await provider.deleteProduct(productId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product deleted successfully!'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete product: $e'),
                          ),
                        );
                      }
                    }
                  }
                }
              : null,
        ),
        body: provider.isLoadingProductDetail
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : provider.productDetailErrorMessage != null
            ? ErrorView(
                errorMessage: provider.productDetailErrorMessage!,
                onRetry: () => provider.fetchProductById(productId),
              )
            : provider.selectedProduct == null ||
                  provider.selectedProduct!.id == 0
            ? const Center(
                child: Text(
                  'Product data not available. It might have been deleted or doesn\'t exist.',
                ),
              )
            : ProductDetails(product: provider.selectedProduct!),
      ),
    );
  }
}
