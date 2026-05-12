import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AmountInput({
    Key? key,
    required this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixIcon: const Icon(Icons.attach_money),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('৳'),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        _AmountFormatter(),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class _AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;
    if (text == '.') {
      return newValue.copyWith(text: '0.');
    }

    final parts = text.split('.');

    // Check integer part limit (8 digits max)
    if (parts[0].length > 8) {
      return oldValue;
    }

    // Check decimal part (2 digits max)
    if (parts.length > 1 && parts[1].length > 2) {
      return oldValue;
    }

    // Don't allow multiple dots
    if (parts.length > 2) {
      return oldValue;
    }

    return newValue;
  }
}
