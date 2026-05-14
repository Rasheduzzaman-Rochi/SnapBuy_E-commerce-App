import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/main_nav_bar.dart';
import '../../../orders/provider/orders_provider.dart';
import '../../../auth/provider/auth_provider.dart';
import '../widgets/order_tile.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _filter = 'All';
  final List<String> _statuses = ['All', 'placed', 'shipped', 'delivered'];
  bool _loadedOrders = false;
  Timer? _snackBarTimer;

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedOrders) return;
    _loadedOrders = true;

    final authProvider = context.read<AuthProvider>();
    context.read<OrdersProvider>().startOrdersListener(
      userEmail: authProvider.userEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders
        .where((order) => _filter == 'All' || order.status == _filter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 74,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1F33), Color(0xFF163C5A), Color(0xFF1F6F8B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statuses.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => ChoiceChip(
                label: Text(_statuses[i].capitalize()),
                selected: _filter == _statuses[i],
                onSelected: (_) => setState(() => _filter = _statuses[i]),
              ),
            ),
          ),
          Expanded(
            child: ordersProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? const Center(child: Text('No orders yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) => OrderTile(
                      order: orders[i],
                      onDelete: () {
                        final removedOrder = orders[i];
                        final ordersProvider = context.read<OrdersProvider>();
                        final messenger = ScaffoldMessenger.of(context);

                        ordersProvider.removeOrderById(removedOrder.id);

                        _snackBarTimer?.cancel();
                        messenger.hideCurrentSnackBar();

                        final snackBarController = messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Order removed'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                _snackBarTimer?.cancel();
                                messenger.hideCurrentSnackBar();

                                ordersProvider.addOrder(removedOrder);
                              },
                            ),
                          ),
                        );

                        _snackBarTimer = Timer(const Duration(seconds: 2), () {
                          if (!mounted) return;
                          snackBarController.close();
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(currentIndex: 2),
    );
  }
}
