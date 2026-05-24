class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;
  final String sellerId;
  final String sellerName;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.sellerId = '',
    this.sellerName = '',
  });

  factory Product.fromFirestore(Map<String, dynamic> doc, String id) {
    final rawPrice = doc['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;

    final rawImage =
        doc['imageUrl'] ??
        doc['imageURL'] ??
        doc['image_url'] ??
        doc['image'] ??
        doc['img'] ??
        doc['thumbnail'];

    return Product(
      id: id,
      name: doc['name'] ?? '',
      price: parsedPrice,
      category: doc['category'] ?? '',
      imageUrl: rawImage?.toString().trim() ?? '',
      description: doc['description'] ?? '',
      sellerId: doc['sellerId']?.toString().trim() ?? '',
      sellerName: doc['sellerName']?.toString().trim() ?? '',
    );
  }
}
