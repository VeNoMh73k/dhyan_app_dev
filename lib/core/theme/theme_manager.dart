import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/main.dart';

  // This method returns the appropriate text color based on the selected theme


   //Splash Screen
    getSplashScreenBackground(){
      if (currentTheme == ThemeData.dark()) {
        return AppColors.blackThemeBackgroundColor; // Dark theme text color
      } else if (currentTheme == ThemeData.light()) {
        return AppColors.whiteThemeBackgroundColor; // Light theme text color
      }
      // Default text color if theme is not specified or invalid
      return AppColors.blackColor;
    }


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
      return AppColors.blackThemeBackgroundColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.whiteThemeBackgroundColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

  getElevationColor(){
    if (currentTheme == ThemeData.dark()) {
      return AppColors.whiteColor.withOpacity(0.1); // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return  AppColors.blackColor.withOpacity(0.1); // Light theme text color
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

getPrimaryColor() {
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
      return AppColors.secondaryColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.whiteColor;
      return AppColors.primaryColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }

  getMusicListTileColor(){
    if (currentTheme == ThemeData.dark()) {
      return AppColors.lightBlackColor; // Dark theme text color
    } else if (currentTheme == ThemeData.light()) {
      return AppColors.whiteColor;
      return AppColors.primaryColor; // Light theme text color
    }
    // Default text color if theme is not specified or invalid
    return AppColors.blackColor;
  }
  
getMusicTileColorWithOpacity(){
  if (currentTheme == ThemeData.dark()) {
    return AppColors.whiteColor.withOpacity(0.05);
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.lightBlackColor.withOpacity(0.1);

    return AppColors.primaryColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}

getPopUpColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.blackThemeBackgroundColor; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.whiteColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}

getUnSelectedRadioButtonColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.unSelectedRadioTileDarkTheme; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.greyColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}


getAudioPlayerIntroductionAndCloseIconColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.primaryColor; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.whiteColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}


getTipPopUpColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.lightBlackColor; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.whiteColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}

getRadioListTileColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.radioTileColorDark; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.textFieldColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}

getSetReminderContainerColor() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.lightBlackColor; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.whiteColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}

getLifeTimePurchaseColorManager() {
  if (currentTheme == ThemeData.dark()) {
    return AppColors.greyColor; // Dark theme text color
  } else if (currentTheme == ThemeData.light()) {
    return AppColors.textFieldColor; // Light theme text color
  }
  // Default text color if theme is not specified or invalid
  return AppColors.blackColor;
}
