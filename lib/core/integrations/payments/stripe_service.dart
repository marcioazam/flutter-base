import 'package:flutter_base_2025/core/errors/failures.dart';
import 'package:flutter_base_2025/core/utils/result.dart';

/// Payment result status.
enum PaymentStatus { success, cancelled, failed }

/// Payment result.
class PaymentResult {

  const PaymentResult({
    required this.status,
    this.paymentIntentId,
    this.errorMessage,
  });
  final PaymentStatus status;
  final String? paymentIntentId;
  final String? errorMessage;

  bool get isSuccess => status == PaymentStatus.success;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isFailed => status == PaymentStatus.failed;
}

/// Payment sheet configuration.
class PaymentSheetConfig {

  const PaymentSheetConfig({
    required this.paymentIntentClientSecret,
    required this.merchantDisplayName, this.customerId,
    this.customerEphemeralKeySecret,
    this.merchantCountryCode = 'US',
    this.googlePayEnabled = true,
    this.applePayEnabled = true,
    this.testMode = false,
  });
  final String paymentIntentClientSecret;
  final String? customerId;
  final String? customerEphemeralKeySecret;
  final String merchantDisplayName;
  final String merchantCountryCode;
  final bool googlePayEnabled;
  final bool applePayEnabled;
  final bool testMode;
}

/// Card details for manual payment.
class CardDetails {

  const CardDetails({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
  });
  final String number;
  final int expiryMonth;
  final int expiryYear;
  final String cvc;

  bool get isValid {
    if (number.replaceAll(' ', '').length < 13) return false;
    if (expiryMonth < 1 || expiryMonth > 12) return false;
    if (expiryYear < DateTime.now().year % 100) return false;
    if (cvc.length < 3) return false;
    return true;
  }
}

/// Abstract payment service interface.
abstract interface class PaymentService {
  /// Initializes the payment service.
  Future<Result<void>> initialize(String publishableKey);

  /// Presents the payment sheet.
  Future<Result<PaymentResult>> presentPaymentSheet(PaymentSheetConfig config);

  /// Confirms a payment with card details.
  Future<Result<PaymentResult>> confirmPayment(
    String clientSecret,
    CardDetails card,
  );

  /// Checks if Apple Pay is available.
  Future<bool> isApplePayAvailable();

  /// Checks if Google Pay is available.
  Future<bool> isGooglePayAvailable();
}

/// Stripe payment service implementation.
/// Note: Requires flutter_stripe package.
class StripePaymentService implements PaymentService {
  bool _initialized = false;

  @override
  Future<Result<void>> initialize(String publishableKey) async {
    try {
      // Placeholder - requires flutter_stripe package
      // Stripe.publishableKey = publishableKey;
      // await Stripe.instance.applySettings();
      _initialized = true;
      return const Success(null);
    } on Exception catch (e) {
      return Failure(UnexpectedFailure('Stripe initialization failed: $e'));
    }
  }

  @override
  Future<Result<PaymentResult>> presentPaymentSheet(
    PaymentSheetConfig config,
  ) async {
    if (!_initialized) {
      return Failure(ValidationFailure('Stripe not initialized'));
    }

    try {
      // Placeholder - requires flutter_stripe package
      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: config.paymentIntentClientSecret,
      //     customerId: config.customerId,
      //     customerEphemeralKeySecret: config.customerEphemeralKeySecret,
      //     merchantDisplayName: config.merchantDisplayName,
      //     googlePay: config.googlePayEnabled
      //         ? PaymentSheetGooglePay(
      //             merchantCountryCode: config.merchantCountryCode,
      //             testEnv: config.testMode,
      //           )
      //         : null,
      //     applePay: config.applePayEnabled
      //         ? PaymentSheetApplePay(
      //             merchantCountryCode: config.merchantCountryCode,
      //           )
      //         : null,
      //   ),
      // );
      //
      // await Stripe.instance.presentPaymentSheet();

      return const Success(PaymentResult(
        status: PaymentStatus.success,
      ));
    } on Exception catch (e) {
      // Handle StripeException for cancellation
      // if (e is StripeException && e.error.code == FailureCode.Canceled) {
      //   return Success(PaymentResult(status: PaymentStatus.cancelled));
      // }
      return Failure(ValidationFailure('Payment failed: $e'));
    }
  }

  @override
  Future<Result<PaymentResult>> confirmPayment(
    String clientSecret,
    CardDetails card,
  ) async {
    if (!_initialized) {
      return Failure(ValidationFailure('Stripe not initialized'));
    }

    if (!card.isValid) {
      return Failure(ValidationFailure('Invalid card details'));
    }

    try {
      // Placeholder - requires flutter_stripe package
      // final paymentIntent = await Stripe.instance.confirmPayment(
      //   paymentIntentClientSecret: clientSecret,
      //   data: PaymentMethodParams.card(
      //     paymentMethodData: PaymentMethodData(
      //       billingDetails: BillingDetails(),
      //     ),
      //   ),
      // );

      return const Success(PaymentResult(
        status: PaymentStatus.success,
      ));
    } on Exception catch (e) {
      return Failure(ValidationFailure('Payment confirmation failed: $e'));
    }
  }

  @override
  Future<bool> isApplePayAvailable() async {
    // Placeholder - requires flutter_stripe package
    // return await Stripe.instance.isApplePaySupported();
    return false;
  }

  @override
  Future<bool> isGooglePayAvailable() async {
    // Placeholder - requires flutter_stripe package
    // return await Stripe.instance.isGooglePaySupported(
    //   IsGooglePaySupportedParams(),
    // );
    return false;
  }
}

/// Payment service factory.
PaymentService createPaymentService() => StripePaymentService();
