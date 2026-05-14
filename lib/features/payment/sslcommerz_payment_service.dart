import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCShipmentInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

// Helper function to check if payment was successful
bool isSslCommerzSuccess(String? status) {
  final value = status?.trim().toLowerCase();
  return value == 'valid' ||
      value == 'validated' ||
      value == 'success' ||
      value == 'successful';
}

// Helper function to check if payment was cancelled
bool isSslCommerzCancelled(String? status) {
  final value = status?.trim().toLowerCase();
  return value == null ||
      value.isEmpty ||
      value == 'closed' ||
      value == 'cancelled' ||
      value == 'canceled' ||
      value == 'failed' ||
      value == 'fail' ||
      value == 'invalid';
}

class SslCommerzPaymentService {
  static Future<SSLCTransactionInfoModel> pay({
    required double amount,
    required String tranId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String customerAddress,
  }) async {
    final storeId = dotenv.env['SSLC_STORE_ID'] ?? '';
    final storePassword = dotenv.env['SSLC_STORE_PASSWORD'] ?? '';

    if (storeId.isEmpty || storePassword.isEmpty) {
      throw Exception('SSLCommerz store id/password missing from .env');
    }

    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        ipn_url: 'https://example.com/ipn',
        multi_card_name: 'visa,master,bkash,nagad',
        currency: SSLCurrencyType.BDT,
        product_category: 'Ecommerce',
        sdkType: SSLCSdkType.TESTBOX,
        store_id: storeId,
        store_passwd: storePassword,
        total_amount: amount,
        tran_id: tranId,
        language: 'en',
      ),
    );

    sslcommerz
        .addShipmentInfoInitializer(
          sslcShipmentInfoInitializer: SSLCShipmentInfoInitializer(
            shipmentMethod: 'yes',
            numOfItems: 1,
            shipmentDetails: ShipmentDetails(
              shipAddress1: customerAddress,
              shipCity: 'Dhaka',
              shipCountry: 'Bangladesh',
              shipName: customerName,
              shipPostCode: '1200',
            ),
          ),
        )
        .addCustomerInfoInitializer(
          customerInfoInitializer: SSLCCustomerInfoInitializer(
            customerState: 'Dhaka',
            customerName: customerName,
            customerEmail: customerEmail,
            customerAddress1: customerAddress,
            customerCity: 'Dhaka',
            customerPostCode: '1200',
            customerCountry: 'Bangladesh',
            customerPhone: customerPhone,
          ),
        );

    return await sslcommerz.payNow();
  }
}
