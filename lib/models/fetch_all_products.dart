import 'dart:convert';

ProductsResponse productsResponseFromJson(String str) =>
    ProductsResponse.fromJson(json.decode(str));

String productsResponseToJson(ProductsResponse data) =>
    json.encode(data.toJson());

class ProductsResponse {
  final int total;
  final int skip;
  final int limit;
  final List<Product> products;

  ProductsResponse({
    required this.total,
    required this.skip,
    required this.limit,
    required this.products,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      ProductsResponse(
        total: json["total"] ?? 0,
        skip: json["skip"] ?? 0,
        limit: json["limit"] ?? 0,
        products: List<Product>.from(
          json["products"]?.map((x) => Product.fromJson(x)) ?? [],
        ),
      );

  Map<String, dynamic> toJson() => {
    "total": total,
    "skip": skip,
    "limit": limit,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String sku;
  final int weight;
  final Dimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final Meta meta;
  final List<String> images;
  final String thumbnail;
  final bool? isDeleted;
  final String? deletedOn;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
    this.isDeleted,
    this.deletedOn,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'misc',
      price: (json['price'] is num ? json['price'].toDouble() : 0.0),
      discountPercentage: (json['discountPercentage'] is num
          ? json['discountPercentage'].toDouble()
          : 0.0),
      rating: (json['rating'] is num ? json['rating'].toDouble() : 0.0),
      stock: json['stock'] is int ? json['stock'] : 0,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((tag) => tag.toString()))
          : [],
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString() ?? '',
      weight: json['weight'] is int ? json['weight'] : 0,
      dimensions: json['dimensions'] != null
          ? Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
          : Dimensions(width: 0.0, height: 0.0, depth: 0.0),
      warrantyInformation: json['warrantyInformation']?.toString() ?? '',
      shippingInformation: json['shippingInformation']?.toString() ?? '',
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      reviews: json['reviews'] != null
          ? (json['reviews'] as List<dynamic>)
                .map((item) => Review.fromJson(item as Map<String, dynamic>))
                .toList()
          : [],
      returnPolicy: json['returnPolicy']?.toString() ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] is int
          ? json['minimumOrderQuantity']
          : 1,
      meta: json['meta'] != null
          ? Meta.fromJson(json['meta'] as Map<String, dynamic>)
          : Meta(createdAt: '', updatedAt: '', barcode: '', qrCode: ''),
      images: json['images'] != null
          ? List<String>.from(json['images'].map((img) => img.toString()))
          : [],
      thumbnail:
          json['thumbnail']?.toString() ?? 'https://via.placeholder.com/150',
      isDeleted: json['isDeleted'] as bool?,
      deletedOn: json['deletedOn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions.toJson(),
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'meta': meta.toJson(),
      'images': images,
      'thumbnail': thumbnail,
      'isDeleted': isDeleted,
      'deletedOn': deletedOn,
    };
  }

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    List<String>? tags,
    String? brand,
    String? sku,
    int? weight,
    Dimensions? dimensions,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    List<Review>? reviews,
    String? returnPolicy,
    int? minimumOrderQuantity,
    Meta? meta,
    List<String>? images,
    String? thumbnail,
    bool? isDeleted,
    String? deletedOn,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      warrantyInformation: warrantyInformation ?? this.warrantyInformation,
      shippingInformation: shippingInformation ?? this.shippingInformation,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      reviews: reviews ?? this.reviews,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      meta: meta ?? this.meta,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedOn: deletedOn ?? this.deletedOn,
    );
  }
}

class Dimensions {
  final double width;
  final double height;
  final double depth;

  Dimensions({required this.width, required this.height, required this.depth});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: (json['width'] is num ? json['width'].toDouble() : 0.0),
      height: (json['height'] is num ? json['height'].toDouble() : 0.0),
      depth: (json['depth'] is num ? json['depth'].toDouble() : 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height, 'depth': depth};
  }
}

class Review {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json['rating'] is int ? json['rating'] : 0,
      comment: json['comment']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? '',
      reviewerEmail: json['reviewerEmail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }
}

class Meta {
  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;

  Meta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'barcode': barcode,
      'qrCode': qrCode,
    };
  }
}
