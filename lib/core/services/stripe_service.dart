import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Stripe payments: client secret must be created by your backend (e.g. Firebase
/// callable with Stripe secret key). Never put Stripe secret key in the app.
class StripeService {
  /// Create a PaymentIntent via backend and present the payment sheet.
  /// Requires a deployed Cloud Function 'createPaymentIntent' with body { amount: number }
  /// returning { clientSecret: string }.
  static Future<bool> pay(int amount) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final result = await functions.httpsCallable('createPaymentIntent').call({'amount': amount});
      final data = result.data as Map<String, dynamic>?;
      final clientSecret = data?['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        print('Stripe: no clientSecret from backend');
        return false;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fitzee',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      print('Stripe error: $e');
      return false;
    }
  }
}
