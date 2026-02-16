const functions = require("firebase-functions");
const { defineSecret } = require("firebase-functions/params");
const stripe = require("stripe");

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

/**
 * Create a Stripe PaymentIntent. Call from the app with { amount: number } (in cents).
 * Returns { clientSecret } for use with Stripe SDK. Stripe secret key must be set in
 * Firebase secrets (STRIPE_SECRET_KEY).
 */
exports.createPaymentIntent = functions
  .https.onCall({ secrets: [stripeSecretKey] }, async (data, context) => {
    const amount = Math.round(Number(data?.amount) || 0);
    if (amount <= 0) {
      throw new functions.https.HttpsError("invalid-argument", "amount must be a positive number (cents)");
    }

    const secret = await stripeSecretKey.value();
    const stripeClient = stripe(secret);

    const paymentIntent = await stripeClient.paymentIntents.create({
      amount,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
    });

    return { clientSecret: paymentIntent.client_secret };
  });
