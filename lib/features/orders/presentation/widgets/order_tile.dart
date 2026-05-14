import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../models/order_model.dart';

class OrderTile extends StatelessWidget {
  final Order order;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final VoidCallback onDelete;

  const OrderTile({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (order.status) {
      case 'placed':
        return const Color(0xFFF2B700);
      case 'shipped':
        return const Color(0xFF2F80ED);
      case 'delivered':
        return const Color(0xFF27AE60);
      default:
        return Colors.grey;
    }
  }

  String get _displayOrderId {
    final raw = order.id.trim();
    if (raw.isEmpty) return '#------';
    if (raw.startsWith('#')) return raw.toUpperCase();

    final trimmed = raw.length > 6 ? raw.substring(0, 6) : raw;
    return '#${trimmed.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: PageStorageKey(order.id),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        tilePadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.receipt_long_outlined,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          'Order $_displayOrderId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy hh:mm a').format(order.createdAt),
        ),
        trailing: Chip(
          label: Text(
            order.status.capitalize(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: _statusColor,
          padding: EdgeInsets.zero,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to: ${order.customerName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  order.customerAddress,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Divider(height: 32),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 138,
                          child: Text(
                            'x${item.quantity} - ৳${(item.price * item.quantity).toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ৳${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.redAccent,
                      tooltip: 'Delete order',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
