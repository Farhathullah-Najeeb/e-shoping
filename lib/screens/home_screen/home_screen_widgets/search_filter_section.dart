import 'package:flutter/material.dart';
import 'package:machine_test_farhathullah/providers/product_provider.dart';
import 'package:machine_test_farhathullah/utils/app_validators.dart';
import 'package:machine_test_farhathullah/utils/debouncer.dart';
import 'package:machine_test_farhathullah/common/custom_input_field.dart';
import 'package:provider/provider.dart';

class SearchFilterSection extends StatefulWidget {
  const SearchFilterSection({super.key});

  @override
  State<SearchFilterSection> createState() => _SearchFilterSectionState();
}

class _SearchFilterSectionState extends State<SearchFilterSection> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  final List<Map<String, String>> _sortOptions = const [
    {'value': 'title_asc', 'label': 'Title (A-Z)'},
    {'value': 'title_desc', 'label': 'Title (Z-A)'},
    {'value': 'price_asc', 'label': 'Price (Low to High)'},
    {'value': 'price_desc', 'label': 'Price (High to Low)'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<ProductProvider>().currentSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Search Bar ---
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: CustomInputField(
                controller: _searchController,
                labelText: 'Search products',
                hintText: 'e.g., Laptop, T-shirt',
                prefixIcon: Icons.search,
                validator: AppValidators.validateSearch,
                onChanged: (value) {
                  _debouncer.run(() {
                    productProvider.searchProducts(value ?? '');
                  });
                },
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.searchProducts('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 18),

            // --- Category Filter + Sort Button ---
            Row(
              children: [
                Expanded(
                  child: productProvider.isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : productProvider.categoriesErrorMessage != null
                      ? Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade400),
                              const SizedBox(height: 8),
                              Text(
                                productProvider.categoriesErrorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                onPressed: () async {
                                  productProvider.clearCategoriesErrorMessage();
                                  await productProvider.fetchCategories();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border.copyWith(
                              borderSide: const BorderSide(
                                color: Colors.deepPurple,
                                width: 1.8,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            fillColor: Colors.grey.shade100,
                            filled: true,
                          ),
                          value: productProvider.currentSelectedCategory.isEmpty
                              ? null
                              : productProvider.currentSelectedCategory,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text(
                                'All Categories',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ...productProvider.categoryList.map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            productProvider.filterByCategory(value ?? '');
                          },
                        ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: Colors.deepPurple.shade200),
                    ),
                    onPressed: () => _showSortOptions(context, productProvider),
                    child: Icon(Icons.tune, color: Colors.deepPurple.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context, ProductProvider productProvider) {
    final sortIconMap = {
      'title_asc': Icons.sort_by_alpha,
      'title_desc': Icons.sort_by_alpha,
      'price_asc': Icons.trending_down,
      'price_desc': Icons.trending_up,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sort by',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sortOptions.map((option) {
                      final valueParts = option['value']!.split('_');
                      final sortKey = valueParts[0];
                      final sortOrder = valueParts[1];
                      final isSelected =
                          productProvider.currentSortKey == sortKey &&
                          productProvider.currentSortOrder == sortOrder;

                      return ChoiceChip(
                        selected: isSelected,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        avatar: Icon(
                          sortIconMap[option['value']!] ?? Icons.sort,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.deepPurple,
                        ),
                        label: Text(option['label']!),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        selectedColor: Colors.deepPurple,
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onSelected: (_) {
                          productProvider.sortProducts(sortKey, sortOrder);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
