// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:machine_test_farhathullah/models/fetch_all_products.dart';
import 'package:machine_test_farhathullah/providers/product_provider.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/custom_app_bar.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/featured_header.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/product_card.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/product_dialog.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/search_filter_section.dart';
import 'package:machine_test_farhathullah/screens/home_screen/home_screen_widgets/welcome_section.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty &&
          productProvider.errorMessage == null) {
        productProvider.fetchProducts();
      }
      if (productProvider.categoryList.isEmpty &&
          productProvider.categoriesErrorMessage == null) {
        productProvider.fetchCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          productProvider.clearFilters();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const CustomAppBar(),
            const WelcomeSection(),
            const SearchFilterSection(),
            FeaturedHeader(
              onClearFilters: () {
                productProvider.clearFilters();
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver:
                  (productProvider.isLoading &&
                      productProvider.products.isEmpty)
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const CircularProgressIndicator(
                                  color: Colors.deepPurple,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Loading amazing products...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : productProvider.errorMessage != null
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[400],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Oops! Something went wrong',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                productProvider.errorMessage ?? 'Unknown error',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  productProvider.clearErrorMessage();
                                  productProvider.fetchProducts();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : productProvider.products.isEmpty
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No products available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (productProvider
                                            .currentSearchQuery
                                            .isNotEmpty ||
                                        productProvider
                                            .currentSelectedCategory
                                            .isNotEmpty)
                                    ? 'No results for your query.'
                                    : 'Check back later for amazing deals!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == productProvider.products.length - 1 &&
                            productProvider.hasMore &&
                            !productProvider.isLoading &&
                            productProvider.currentSearchQuery.isEmpty &&
                            productProvider.currentSelectedCategory.isEmpty) {
                          productProvider.fetchProducts(loadMore: true);
                        }
                        final product = productProvider.products[index];
                        return ProductCard(
                          product: product,
                          onEdit: (context, product) {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  ProductDialog(isEdit: true, product: product),
                            );
                          },
                        );
                      }, childCount: productProvider.products.length),
                    ),
            ),
            if (productProvider.isLoading &&
                productProvider.products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/waiting.json',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ProductDialog(isEdit: false),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
