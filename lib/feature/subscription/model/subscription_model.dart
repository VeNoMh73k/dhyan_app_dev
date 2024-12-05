import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionModel{
  String? id;
  String? mainId;
  String? title;
  String? description;
  String? price;
  double? rawPrice;
  String? duration;

  SubscriptionModel({this.id,this.price,this.title,this.duration});
}

extension SubscriptionModelExtension on SubscriptionModel {
  ProductDetails toProductDetails() {
    // Assuming you have the mapping logic
    return ProductDetails(
      id: this.id ?? "",
      title: this.title ?? "",
      description: "Subscription for ${this.duration}",
      price: this.price ?? "",
      rawPrice: double.parse(this.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? ""), // Parse numeric price
      currencyCode: "USD", // Update this to dynamic currency if needed
    );
  }
}
