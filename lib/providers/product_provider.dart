import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machine_test_farhathullah/models/chategory_model.dart'
    as my_models;
import 'package:machine_test_farhathullah/models/fetch_all_products.dart';
import 'package:machine_test_farhathullah/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;

  ProductProvider(this._productService) {
    fetchCategories();
  }

  final List<Product> _products = [];
  Product? _selectedProduct;
  String _searchQuery = '';
  String _selectedCategory = '';
  int _currentPage = 0;
  final int _pageSize = 10;
  String _sortBy = 'title';
  String _order = 'asc';
  bool _hasMore = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool _isAddingUpdating = false;
  String? _dialogSelectedCategory;
  String? _selectedThumbnailPath;
  List<String> _selectedImagePaths = [];

  List<my_models.Category> _categories = [];
  List<String> _categoryList = [];
  bool _isLoadingCategories = false;
  String? _categoriesErrorMessage;

  bool _isLoadingProductDetail = false;
  String? _productDetailErrorMessage;

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  List<my_models.Category> get categories => _categories;
  List<String> get categoryList => _categoryList;
  bool get isLoading => _isLoading;
  bool get isAddingUpdating => _isAddingUpdating;
  bool get isLoadingProductDetail => _isLoadingProductDetail;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get errorMessage => _errorMessage;
  String? get productDetailErrorMessage => _productDetailErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;
  bool get hasMore => _hasMore;
  String get currentSearchQuery => _searchQuery;
  String get currentSelectedCategory => _selectedCategory;
  String get currentSortKey => _sortBy;
  String get currentSortOrder => _order;

  String? get selectedThumbnailPath => _selectedThumbnailPath;
  List<String> get selectedImagePaths => _selectedImagePaths;
  String? get dialogSelectedCategory => _dialogSelectedCategory;

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (_isLoading || (loadMore && !_hasMore)) return;

    _isLoading = true;
    _errorMessage = null;

    if (!loadMore) {
      _products.clear();
      _currentPage = 0;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final skip = _currentPage * _pageSize;
      List<Product> newProducts = await _productService.getProducts(
        limit: _pageSize,
        skip: skip,
        sortBy: _sortBy,
        order: _order,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      );

      _products.addAll(newProducts);
      _errorMessage = null;

      _hasMore = newProducts.length == _pageSize;

      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', 'Error: ');
      _hasMore = false;
      if (!loadMore) {
        _products.clear();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductById(int id) async {
    if (_isLoadingProductDetail) return;
    _isLoadingProductDetail = true;
    _productDetailErrorMessage = null;
    notifyListeners();

    try {
      final localProduct = _products.firstWhere(
        (p) => p.id == id,
        orElse: () => Product(
          id: 0,
          title: '',
          description: '',
          category: '',
          price: 0.0,
          discountPercentage: 0.0,
          rating: 0.0,
          stock: 0,
          tags: [],
          brand: null,
          sku: '',
          weight: 0,
          dimensions: Dimensions(width: 0.0, height: 0.0, depth: 0.0),
          warrantyInformation: '',
          shippingInformation: '',
          availabilityStatus: '',
          reviews: [],
          returnPolicy: '',
          minimumOrderQuantity: 1,
          meta: Meta(createdAt: '', updatedAt: '', barcode: '', qrCode: ''),
          images: [],
          thumbnail: 'https://via.placeholder.com/150',
          isDeleted: null,
          deletedOn: null,
        ),
      );

      if (localProduct.id != 0) {
        _selectedProduct = localProduct;
      } else {
        _selectedProduct = await _productService.getProductById(id);
      }
      _productDetailErrorMessage = null;
    } catch (e) {
      _productDetailErrorMessage =
          'Failed to load product detail: ${e.toString().replaceFirst('Exception: ', '')}';
      _selectedProduct = null;
    } finally {
      _isLoadingProductDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    if (_isLoadingCategories) return;
    _isLoadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      _categories = await _productService.getCategories();
      _categoryList = await _productService.getCategoryList();
      _categoriesErrorMessage = null;
    } catch (e) {
      _categoriesErrorMessage =
          'Failed to load categories: ${e.toString().replaceFirst('Exception: ', '')}';
      _categories = [];
      _categoryList = [];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<String?> _uploadImage(String? path) async {
    if (path == null) return null;

    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Simulating upload of image from path: $path');

    return 'https://example.com/uploaded_images/${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    _isAddingUpdating = true;
    notifyListeners();
    try {
      productData['thumbnail'] = await _uploadImage(_selectedThumbnailPath);

      List<String> imageUrls = [];
      for (String path in _selectedImagePaths) {
        final imageUrl = await _uploadImage(path);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      productData['images'] = imageUrls;

      final newProduct = await _productService.addProduct(productData);

      _products.insert(0, newProduct);
      clearDialogState();
    } catch (e) {
      throw Exception(
        'Failed to add product: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      _isAddingUpdating = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    _isAddingUpdating = true;
    notifyListeners();
    try {
      if (_selectedThumbnailPath != null &&
          !_selectedThumbnailPath!.startsWith('http')) {
        productData['thumbnail'] = await _uploadImage(_selectedThumbnailPath);
      } else if (_selectedThumbnailPath == null) {
        productData['thumbnail'] = '';
      } else {
        productData['thumbnail'] = _selectedThumbnailPath;
      }

      List<String> updatedImageUrls = [];
      for (String path in _selectedImagePaths) {
        if (path.startsWith('http')) {
          updatedImageUrls.add(path);
        } else {
          final imageUrl = await _uploadImage(path);
          if (imageUrl != null) {
            updatedImageUrls.add(imageUrl);
          }
        }
      }
      productData['images'] = updatedImageUrls;

      final updatedProduct = await _productService.updateProduct(
        id,
        productData,
      );
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      if (_selectedProduct?.id == id) {
        _selectedProduct = updatedProduct;
      }
      clearDialogState();
    } catch (e) {
      throw Exception(
        'Failed to update product: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      _isAddingUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isAddingUpdating = true;
    notifyListeners();
    try {
      final deletedProduct = await _productService.deleteProduct(id);

      _products.removeWhere((p) => p.id == id);

      if (_selectedProduct?.id == id) {
        _selectedProduct = deletedProduct;
      }
    } catch (e) {
      throw Exception(
        'Failed to delete product: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      _isAddingUpdating = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    if (_searchQuery != query.toLowerCase()) {
      _searchQuery = query.toLowerCase();
      _selectedCategory = '';

      _currentPage = 0;
      _hasMore = true;
      _products.clear();
      fetchProducts(loadMore: false);
    }
  }

  void filterByCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _searchQuery = '';

      _currentPage = 0;
      _hasMore = true;
      _products.clear();
      fetchProducts(loadMore: false);
    }
  }

  void sortProducts(String sortBy, String order) {
    if (_sortBy != sortBy || _order != order) {
      _sortBy = sortBy;
      _order = order;

      _currentPage = 0;
      _hasMore = true;
      _products.clear();
      fetchProducts(loadMore: false);
    }
  }

  void clearFilters() {
    if (_searchQuery.isNotEmpty ||
        _selectedCategory.isNotEmpty ||
        _sortBy != 'title' ||
        _order != 'asc') {
      _searchQuery = '';
      _selectedCategory = '';
      _sortBy = 'title';
      _order = 'asc';

      _currentPage = 0;
      _products.clear();
      _hasMore = true;
      fetchProducts(loadMore: false);
    }
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearProductDetailErrorMessage() {
    if (_productDetailErrorMessage != null) {
      _productDetailErrorMessage = null;
      notifyListeners();
    }
  }

  void clearCategoriesErrorMessage() {
    if (_categoriesErrorMessage != null) {
      _categoriesErrorMessage = null;
      notifyListeners();

      fetchCategories();
    }
  }

  void setThumbnailPath(String? path) {
    if (_selectedThumbnailPath != path) {
      _selectedThumbnailPath = path;
      notifyListeners();
    }
  }

  Future<void> pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setThumbnailPath(pickedFile.path);
    }
  }

  void setImagePaths(List<String> paths) {
    _selectedImagePaths = List.from(paths);
    notifyListeners();
  }

  void removeImagePath(String path) {
    if (_selectedImagePaths.remove(path)) {
      notifyListeners();
    }
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setImagePaths(pickedFiles.map((file) => file.path).toList());
    }
  }

  void setDialogCategory(String? category) {
    if (_dialogSelectedCategory != category) {
      _dialogSelectedCategory = category;
      notifyListeners();
    }
  }

  void clearDialogState() {
    _selectedThumbnailPath = null;
    _selectedImagePaths = [];
    _dialogSelectedCategory = null;
    notifyListeners();
  }
}
