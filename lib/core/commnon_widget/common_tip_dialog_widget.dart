import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';

class TipDialogBox extends StatefulWidget {
  final List<ProductDetails> subscriptionList;
  final Function(ProductDetails selectedSubscription) onSubmit;

  const TipDialogBox({
    Key? key,
    required this.subscriptionList,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<TipDialogBox> createState() => _TipDialogBoxState();
}

class _TipDialogBoxState extends State<TipDialogBox> {

  int selectedIndex = 0; // Default to the first item being selected
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: getTipPopUpColor(),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: AppUtils.commonContainer(
                  margin: const EdgeInsets.only(right: 15, top: 15),
                  height: 28,
                  width: 28,
                  decoration: AppUtils.commonBoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blackColor,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
            // Title and description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  AppUtils.commonTextWidget(
                    text: "Tip Us",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 12),
                  AppUtils.commonTextWidget(
                    text: "Tip us to provide more free track, Select amount you want to tip us.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Dynamically generated tip options
                  ...List.generate(widget.subscriptionList.length, (index) {
                    final subscription = widget.subscriptionList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColors.textFieldColor,
                        ),
                        child: RadioListTile<int>(
                          fillColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return getPrimaryColor();
                            }
                            return getUnSelectedRadioButtonColor();
                          }),
                          tileColor: getRadioListTileColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: AppUtils.commonTextWidget(
                            text: subscription.price,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          value: index,
                          groupValue: selectedIndex,
                          activeColor: AppColors.secondaryColor,
                          onChanged: (value) {
                            setState(() {
                              selectedIndex = value!;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 26),
                  // Submit button
                  AppUtils.commonElevatedButton(
                    bottomMargin: 30,
                    leftPadding: 25,
                    rightPadding: 25,
                    buttonWidth: 170,
                    topPadding: 12,
                    bottomPadding: 12,
                    text: "Provide Tip",
                    fontWeight: FontWeight.w500,
                    onPressed: () {
                      final selectedSubscription =
                      widget.subscriptionList[selectedIndex];
                      widget.onSubmit(selectedSubscription);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}