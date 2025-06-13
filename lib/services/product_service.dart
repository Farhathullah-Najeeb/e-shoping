// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:machine_test_farhathullah/models/chategory_model.dart';
import 'package:machine_test_farhathullah/models/fetch_all_products.dart';
import 'package:machine_test_farhathullah/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductService {
  final ApiService _apiService;
  static const String _localProductsKey = 'local_products';
  final Map<int, Product> _localProductsCache = {};

  ProductService(this._apiService) {
    _loadLocalProductsCache();
  }

  Future<void> _loadLocalProductsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final localProductsJson = prefs.getString(_localProductsKey);
    if (localProductsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(localProductsJson);
        for (var json in jsonList) {
          final product = Product.fromJson(json);
          _localProductsCache[product.id] = product;
        }
        print('Loaded ${_localProductsCache.length} local products into cache');
      } catch (e) {
        print('Error loading local products cache: $e');
      }
    }
  }

  Future<void> _saveLocalProduct(Product product) async {
    _localProductsCache[product.id] = product;
    final prefs = await SharedPreferences.getInstance();
    final localProducts = _localProductsCache.values.toList();
    try {
      final jsonList = localProducts.map((p) => p.toJson()).toList();
      await prefs.setString(_localProductsKey, jsonEncode(jsonList));
      print('Saved ${localProducts.length} local products');
    } catch (e) {
      print('Error saving local products: $e');
    }
  }

  Future<List<Product>> getProducts({
    String? searchQuery,
    String? category,
    int limit = 10,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    try {
      Map<String, dynamic> responseData;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        responseData = await _apiService.get(
          '/products/search',
          queryParameters: {'q': searchQuery, 'limit': limit, 'skip': skip},
        );
      } else if (category != null && category.isNotEmpty) {
        responseData = await _apiService.get(
          '/products/category/$category',
          queryParameters: {'limit': limit, 'skip': skip},
        );
      } else {
        final queryParams = <String, dynamic>{
          'limit': limit,
          'skip': skip,
          if (sortBy != null) 'sortBy': sortBy,
          if (order != null) 'order': order,
        };
        responseData = await _apiService.get(
          '/products',
          queryParameters: queryParams,
        );
      }

      final apiProducts = (responseData['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList();

      // Add local products with IDs > 100000
      final localProducts = _localProductsCache.values
          .where(
            (p) =>
                p.id > 100000 &&
                (category == null || p.category == category) &&
                (searchQuery == null ||
                    p.title.toLowerCase().contains(searchQuery.toLowerCase())),
          )
          .toList();

      final allProducts = [...apiProducts, ...localProducts];
      // Sort and paginate combined list
      if (sortBy != null) {
        allProducts.sort((a, b) {
          if (sortBy == 'title') {
            return order == 'desc'
                ? b.title.compareTo(a.title)
                : a.title.compareTo(b.title);
          } else if (sortBy == 'price') {
            return order == 'desc'
                ? b.price.compareTo(a.price)
                : a.price.compareTo(b.price);
          }
          return 0;
        });
      }
      // Apply pagination
      final start = skip;
      final end = (skip + limit).clamp(0, allProducts.length);
      return allProducts.sublist(
        start,
        end < allProducts.length ? end : allProducts.length,
      );
    } on DioException catch (e) {
      print('API Request Failed in getProducts: ${e.message}');
      throw Exception('Failed to fetch products: ${e.message}');
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      if (id > 100000 && _localProductsCache.containsKey(id)) {
        print('Returning local product $id from cache');
        return _localProductsCache[id]!;
      }
      final responseData = await _apiService.get('/products/$id');
      return Product.fromJson(responseData);
    } on DioException catch (e) {
      print('API Request Failed in getProductById: ${e.message}');
      throw Exception('Failed to fetch product by ID: ${e.message}');
    } catch (e) {
      print('Error in getProductById: $e');
      throw Exception('Failed to fetch product by ID: $e');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final responseData = await _apiService.get('/products/categories');
      return (responseData as List)
          .map((item) => Category.fromJson(item))
          .toList();
    } on DioException catch (e) {
      print('API Request Failed in getCategories: ${e.message}');
      throw Exception('Failed to fetch categories: ${e.message}');
    } catch (e) {
      print('Error in getCategories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<String>> getCategoryList() async {
    try {
      final responseData = await _apiService.get('/products/category-list');
      return (responseData as List).cast<String>();
    } on DioException catch (e) {
      print('API Request Failed in getCategoryList: ${e.message}');
      throw Exception('Failed to fetch category list: ${e.message}');
    } catch (e) {
      print('Error in getCategoryList: $e');
      throw Exception('Failed to fetch category list: $e');
    }
  }

  Future<Product> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = Product.fromJson({
        ...productData,
        'id': 100001 + (_localProductsCache.length % 100000),
        'rating': productData['rating'] ?? 4.5,
        'stock': productData['stock'] ?? 100,
        'reviews': productData['reviews'] ?? [],
        'meta':
            productData['meta'] ??
            {
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
              'barcode': 'NEWBARCODE${DateTime.now().millisecondsSinceEpoch}',
              'qrCode': 'NEWQRCODE${DateTime.now().millisecondsSinceEpoch}',
            },
        'thumbnail':
            productData['thumbnail'] ?? 'https://via.placeholder.com/150',
        'images': productData['images'] ?? [],
        'dimensions':
            productData['dimensions'] ??
            {'width': 10.0, 'height': 10.0, 'depth': 10.0},
        'weight': productData['weight'] ?? 1,
        'warrantyInformation':
            productData['warrantyInformation'] ?? 'No warranty',
        'shippingInformation':
            productData['shippingInformation'] ?? 'Ships in 1 week',
        'availabilityStatus': productData['availabilityStatus'] ?? 'In Stock',
        'returnPolicy': productData['returnPolicy'] ?? '30 days return policy',
        'minimumOrderQuantity': productData['minimumOrderQuantity'] ?? 1,
      });
      await _saveLocalProduct(newProduct);
      print('Added local product ${newProduct.id}');
      return newProduct;
    } catch (e) {
      print('Error in addProduct: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> productData,
  ) async {
    try {
      if (id > 100000) {
        final existingProduct = _localProductsCache[id];
        if (existingProduct == null) {
          throw Exception('Local product $id not found');
        }
        final updatedProduct = Product.fromJson({
          ...existingProduct.toJson(),
          ...productData,
          'id': id,
          'meta': {
            ...existingProduct.meta.toJson(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        });
        await _saveLocalProduct(updatedProduct);
        print('Updated local product $id');
        return updatedProduct;
      } else {
        final responseData = await _apiService.put(
          '/products/$id',
          data: productData,
        );
        return Product.fromJson(responseData);
      }
    } on DioException catch (e) {
      print('API Request Failed in updateProduct: ${e.message}');
      throw Exception('Failed to update product: ${e.message}');
    } catch (e) {
      print('Error in updateProduct: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<Product> deleteProduct(int id) async {
    try {
      if (id > 100000) {
        final product = _localProductsCache[id];
        if (product == null) {
          throw Exception('Local product $id not found');
        }
        _localProductsCache.remove(id);
        final prefs = await SharedPreferences.getInstance();
        final localProducts = _localProductsCache.values.toList();
        final jsonList = localProducts.map((p) => p.toJson()).toList();
        await prefs.setString(_localProductsKey, jsonEncode(jsonList));
        print('Deleted local product $id');
        return product;
      } else {
        final responseData = await _apiService.delete('/products/$id');
        return Product.fromJson(responseData);
      }
    } on DioException catch (e) {
      print('API Request Failed in deleteProduct: ${e.message}');
      throw Exception('Failed to delete product: ${e.message}');
    } catch (e) {
      print('Error in deleteProduct: $e');
      throw Exception('Failed to delete product: $e');
    }
  }
}
