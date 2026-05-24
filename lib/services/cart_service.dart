import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/cart/models/cart_item.dart';
import '../models/product_model.dart';

class CartService {
  CartService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;

  String _requireUserId([
    String message = 'Please login to add items to cart',
  ]) {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception(message);
    }
    return uid;
  }

  Future<T> _runCartOperation<T>(
    Future<T> Function() operation,
    String fallbackMessage,
  ) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      final message = e.code == 'permission-denied'
          ? 'Please login to manage your cart'
          : e.message ?? fallbackMessage;
      throw Exception(message);
    }
  }

  CollectionReference<Map<String, dynamic>> _cartCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  Future<void> addToCart(Product product, int quantity) async {
    if (quantity <= 0) return;

    final uid = _requireUserId();
    final cartItemRef = _cartCollection(uid).doc(product.id);

    await _runCartOperation(() async {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(cartItemRef);
        final currentQuantity = snapshot.exists
            ? (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0
            : 0;
        final newQuantity = currentQuantity + quantity;

        final data = <String, dynamic>{
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'sellerId': product.sellerId,
          'sellerName': product.sellerName,
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (snapshot.exists) {
          transaction.set(cartItemRef, data, SetOptions(merge: true));
        } else {
          transaction.set(cartItemRef, {
            ...data,
            'addedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    }, 'Unable to add item to cart. Please try again.');
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    final uid = _requireUserId('Please login to manage your cart');
    final cartItemRef = _cartCollection(uid).doc(productId);

    await _runCartOperation(() async {
      if (quantity <= 0) {
        await cartItemRef.delete();
        return;
      }

      await cartItemRef.set({
        'productId': productId,
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }, 'Unable to update cart quantity. Please try again.');
  }

  Future<void> removeFromCart(String productId) async {
    final uid = _requireUserId('Please login to manage your cart');
    await _runCartOperation(() async {
      await _cartCollection(uid).doc(productId).delete();
    }, 'Unable to remove item from cart. Please try again.');
  }

  Future<void> clearUserCart() async {
    final uid = _requireUserId('Please login to manage your cart');
    await _runCartOperation(() async {
      final snapshot = await _cartCollection(uid).get();

      for (var i = 0; i < snapshot.docs.length; i += 450) {
        final batch = _firestore.batch();
        final chunk = snapshot.docs.skip(i).take(450);
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }, 'Unable to clear cart. Please try again.');
  }

  Future<List<CartItem>> fetchUserCart() async {
    final uid = _requireUserId('Please login to manage your cart');
    return _runCartOperation(() async {
      final snapshot = await _cartCollection(uid).get();
      return snapshot.docs.map((doc) => _cartItemFromFirestore(doc)).toList();
    }, 'Unable to load cart. Please try again.');
  }

  Stream<List<CartItem>> watchUserCart() {
    final uid = _requireUserId();
    return _cartCollection(uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => _cartItemFromFirestore(doc)).toList(),
    );
  }

  CartItem _cartItemFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final rawPrice = data['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0;
    final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

    return CartItem(
      product: Product(
        id: data['productId']?.toString().trim().isNotEmpty == true
            ? data['productId'].toString().trim()
            : doc.id,
        name: data['name']?.toString() ?? '',
        price: price,
        category: data['category']?.toString() ?? '',
        imageUrl: data['imageUrl']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        sellerId: data['sellerId']?.toString() ?? '',
        sellerName: data['sellerName']?.toString() ?? '',
      ),
      quantity: quantity,
    );
  }
}
