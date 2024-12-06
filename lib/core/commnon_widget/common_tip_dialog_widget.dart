import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<String> options; // Pass options like price or tips
  final Function(int selectedIndex) onSubmit;

  const CommonDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.options,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0; // Default selection

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: getPopUpColor(),
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
                        text: title,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 12),
                      AppUtils.commonTextWidget(
                        text: description,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Dynamically generated options
                      ...List.generate(options.length, (index) {
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
                                return AppColors.greyColor;
                              }),
                              tileColor: AppColors.textFieldColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: AppUtils.commonTextWidget(
                                text: options[index],
                                textColor: AppColors.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                              value: index,
                              groupValue: selectedIndex,
                              activeColor: getPrimaryColor(),
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
                        text: "Submit",
                        fontWeight: FontWeight.w500,
                        onPressed: () {
                          onSubmit(selectedIndex);
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
      },
    );
  }
}
