import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/constants.dart';

InAppPurchase _inAppPurchase = InAppPurchase.instance;
late StreamSubscription<dynamic> _streamSubscription;
List<ProductDetails> _products = [];
const _variant = {"meditationapp", "meditation pro"};

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Make a donation',
          style: TextStyle(fontFamily: fontFamily),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://images.pexels.com/photos/346885/pexels-photo-346885.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia. \n\nLooked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage \n \n- Makers of Meditaion App',
                style: TextStyle(fontSize: 15, fontFamily: fontFamily),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          openDialog();
                        },
                        child: Text(
                          'Donate Once',
                          style: TextStyle(fontFamily: fontFamily),
                        ))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          openDialog();
                        },
                        child: Text(
                          'Join the Circle',
                          style: TextStyle(fontFamily: fontFamily),
                        ))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  openDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PaymentDialog();
      },
    );
  }
}

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _streamSubscription = purchaseUpdated.listen((purchaseList) {
      _listenToPurchase(purchaseList, context);
    }, onDone: () {
      _streamSubscription.cancel();
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Error",
        style: TextStyle(fontFamily: fontFamily),
      )));
    });
    initStore();
  }

  initStore() async {
    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(_variant);
    if (productDetailsResponse.error == null) {
      setState(() {
        _products = productDetailsResponse.productDetails;
      });
    }
  }

  _listenToPurchase(
      List<PurchaseDetails> purchaseDetailsList, BuildContext context) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Pending",style: TextStyle(fontFamily: fontFamily),)));
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error",style: TextStyle(fontFamily: fontFamily),)));
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Purchased", style: TextStyle(fontFamily: fontFamily),)));
      }
    });
  }

  _buy() {
    final PurchaseParam param = PurchaseParam(productDetails: _products[0]);
    _inAppPurchase.buyConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Donate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,fontFamily: fontFamily)),
          const SizedBox(height: 20),
          Column(
            children: ["40.00", "120.00", "400.00", "1000.00"]
                .map(
                  (amount) => ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _buy();
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return PaymentBtnDialog(
                      //       amount: amount,
                      //     );
                      //   },
                      // );
                    },
                    minLeadingWidth: 5,
                    title: Text('₹$amount',style: TextStyle(fontFamily: fontFamily),),
                    leading: const Icon(Icons.circle_outlined, size: 20),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'We run entirely on donations, so every donation helps us keep the app running.',
            style: TextStyle(fontSize: 14,fontFamily: fontFamily),
          ),
        ],
      ),
    );
  }
}

// class PaymentBtnDialog extends StatefulWidget {
//   final String amount;
//
//   const PaymentBtnDialog({super.key, required this.amount});
//
//   @override
//   State<PaymentBtnDialog> createState() => _PaymentBtnDialogState();
// }
//
// class _PaymentBtnDialogState extends State<PaymentBtnDialog> {
//   // late ApplePayButton applePayButton;
//   // late GooglePayButton googlePayButton;
//
//   // @override
//   // void initState() {
//   //   initGooglePay();
//   //   if (Platform.isIOS) {
//   //     initAppleAay();
//   //   }
//   //   super.initState();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text('Payment Method',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 20),
//           // googlePayButton,
//           // if (Platform.isIOS) applePayButton
//         ],
//       ),
//     );
//   }
//
//   // initGooglePay() {
//   //   googlePayButton = GooglePayButton(
//   //     paymentConfiguration:
//   //         PaymentConfiguration.fromJsonString(defaultGooglePay),
//   //     paymentItems: [
//   //       PaymentItem(
//   //           amount: widget.amount,
//   //           label: 'Payment',
//   //           status: PaymentItemStatus.final_price,
//   //           type: PaymentItemType.total),
//   //     ],
//   //     type: GooglePayButtonType.buy,
//   //     margin: const EdgeInsets.only(top: 15.0),
//   //     onPaymentResult: onGooglePayResult,
//   //     loadingIndicator: const Center(
//   //       child: CircularProgressIndicator(),
//   //     ),
//   //   );
//   // }
//   //
//   // initAppleAay() {
//   //   applePayButton = ApplePayButton(
//   //     paymentConfiguration:
//   //         PaymentConfiguration.fromJsonString(defaultApplePay),
//   //     paymentItems: [
//   //       PaymentItem(
//   //           amount: widget.amount,
//   //           label: 'Payment',
//   //           status: PaymentItemStatus.final_price,
//   //           type: PaymentItemType.total),
//   //     ],
//   //     style: ApplePayButtonStyle.black,
//   //     type: ApplePayButtonType.buy,
//   //     margin: const EdgeInsets.only(top: 15.0),
//   //     onPaymentResult: onApplePayResult,
//   //     loadingIndicator: const Center(
//   //       child: CircularProgressIndicator(),
//   //     ),
//   //   );
//   // }
//   //
//   // static void onApplePayResult(paymentResult) {
//   //   // Send the resulting Apple Pay token to your server / PSP
//   //   debugPrint(paymentResult.toString());
//   // }
//   //
//   // static void onGooglePayResult(paymentResult) {
//   //   // Send the resulting Google Pay token to your server / PSP
//   //   debugPrint(paymentResult.toString());
//   // }
// }
