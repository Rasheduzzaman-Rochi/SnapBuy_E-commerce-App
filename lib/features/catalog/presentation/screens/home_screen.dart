import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/main_nav_bar.dart';
import '../../../../models/product_model.dart';
import '../../../cart/provider/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  final _productsStream = FirebaseFirestore.instance
      .collection('products')
      .snapshots();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1F33), Color(0xFF163C5A), Color(0xFF1F6F8B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const AppLogo(
          size: 38,
          subtitle: 'Premium shopping',
          textColor: Colors.white,
          subtitleColor: Color(0xC7FFFFFF),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${cart.itemCount} items',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(
            searchController: searchController,
            searchQuery: searchQuery,
            onChanged: (value) => setState(() => searchQuery = value),
            onClear: () {
              searchController.clear();
              setState(() => searchQuery = '');
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load products: ${snapshot.error}'),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                    .toList();

                final categories = <String>[
                  'All',
                  ...{
                    for (final product in allProducts)
                      if (product.category.trim().isNotEmpty) product.category,
                  },
                ];

                final visibleProducts = allProducts
                    .where(
                      (product) =>
                          _selectedCategory == 'All' ||
                          product.category == _selectedCategory,
                    )
                    .where(
                      (product) =>
                          searchQuery.isEmpty ||
                          product.name.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                if (allProducts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No products found in Firestore.'),
                    ),
                  );
                }

                return Column(
                  children: [
                    CategoryFilter(
                      categories: categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) =>
                          setState(() => _selectedCategory = category),
                    ),
                    Expanded(child: _buildProductGrid(visibleProducts)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 0),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No matching products found',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different product name or category.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductCard(
        imageUrl: products[i].imageUrl,
        name: products[i].name,
        price: products[i].price,
        onTap: () => Navigator.pushNamed(
          ctx,
          AppRoutes.productDetail,
          arguments: products[i],
        ),
      ),
    );
  }
}
