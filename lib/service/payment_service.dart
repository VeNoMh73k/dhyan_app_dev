// import 'package:flutter/material.dart';
// import 'package:meditationapp/service/payment_configurations.dart';
// import 'package:pay/pay.dart';
//
// class PaymentService {
//   ApplePayButton applePayButton = ApplePayButton(
//     paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
//     paymentItems: const [
//       PaymentItem(
//           amount: '100',
//           label: 'Payment',
//           status: PaymentItemStatus.final_price,
//           type: PaymentItemType.total),
//     ],
//     style: ApplePayButtonStyle.black,
//     type: ApplePayButtonType.buy,
//     margin: const EdgeInsets.only(top: 15.0),
//     onPaymentResult: onApplePayResult,
//     loadingIndicator: const Center(
//       child: CircularProgressIndicator(),
//     ),
//   );
//
//   GooglePayButton googlePayButton = GooglePayButton(
//     paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
//     paymentItems: const [
//       PaymentItem(
//           amount: '100',
//           label: 'Payment',
//           status: PaymentItemStatus.final_price,
//           type: PaymentItemType.total),
//     ],
//     type: GooglePayButtonType.buy,
//     margin: const EdgeInsets.only(top: 15.0),
//     onPaymentResult: onGooglePayResult,
//     loadingIndicator: const Center(
//       child: CircularProgressIndicator(),
//     ),
//   );
//
//   static void onApplePayResult(paymentResult) {
//     // Send the resulting Apple Pay token to your server / PSP
//     debugPrint(paymentResult.toString());
//   }
//
//   static void onGooglePayResult(paymentResult) {
//     // Send the resulting Google Pay token to your server / PSP
//     debugPrint(paymentResult.toString());
//   }
// }
