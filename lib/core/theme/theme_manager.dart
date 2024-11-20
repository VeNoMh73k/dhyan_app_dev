import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/main.dart';

  // This method returns the appropriate text color based on the selected theme
    getTextColor() {
    if (currentTheme == ThemeData.dark()) {
      return AppColors.whiteColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.blackColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

    getScaffoldColor() {
    if (currentTheme == ThemeData.dark()) {
      return AppColors.blackColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.whiteColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

    getTipIconColor() {
    if (currentTheme == ThemeData.dark()) {
      return AppColors.secondaryColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.primaryColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

  getBottomRowContainerColor() {
    print("ThemeData${ThemeMode.system.toString()}");
    if (currentTheme == ThemeData.dark()) {
      return AppColors.blackColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.primaryColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

    getLogoColor() {
    if (currentTheme == ThemeData.dark()) {
       // Dark theme text color
      return AppColors.primaryColor;
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.blackColor;
       // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

    getBottomCountContainerColor() {
    if (currentTheme == ThemeData.dark()) {
      return AppColors.primaryColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.whiteColor;
      return AppColors.primaryColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }
