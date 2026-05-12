import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class DummyPaymentScreen extends StatefulWidget {
  const DummyPaymentScreen({
    super.key,
    required this.amount,
    required this.title,
  });

  final double amount;
  final String title;

  @override
  State<DummyPaymentScreen> createState() => _DummyPaymentScreenState();
}

class _DummyPaymentScreenState extends State<DummyPaymentScreen> {
  bool _isProcessing = false;

  Future<void> _completePayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  void _cancelPayment() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvasColor,
      appBar: AppBar(
        title: const Text('Dummy Payment'),
        backgroundColor: Colors.white,
        foregroundColor: kTitleTextColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.payment_rounded,
                  size: 56,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Snapbuy Dummy Gateway',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kTitleTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kMutedTextColor, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  formatCurrency(widget.amount),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _completePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Pay Successfully',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isProcessing ? null : _cancelPayment,
                  child: const Text('Cancel Payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
