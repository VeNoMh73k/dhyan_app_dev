import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: AppUtils.commonTextWidget(
          text: "About Us",
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16,top: 8,bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUtils.commonTextWidget(
                  text:
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n\nIt has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\nMeditation Track Composed By:",
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.blackColor,
                  fontSize: 15,
                  overflow: TextOverflow.visible),
              AppUtils.commonTextWidget(
                  text:
                      "RJ Alex Carry, John Doe, Virat Kohli",
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.blackColor,
                  fontSize: 15,
                  overflow: TextOverflow.visible),
            ],
          ),
        ),
      ),
    );
  }
}
