import 'dart:convert';

import 'package:fitzee_new/main.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static Future<bool> pay(int amount) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $secretKey',
      },
      body: {
        'amount': '${amount}',
        'currency': 'usd',
        'automatic_payment_methods[enabled]': 'true',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final clientSecret = jsonDecode(response.body)['client_secret'];

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fitzee',
        ),
      );

      await Stripe.instance.presentPaymentSheet(); // ✅ only once
      return true;
    } catch (e) {
      print('Stripe error: $e');
      return false;
    }

  }
}
