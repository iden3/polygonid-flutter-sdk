import 'package:flutter/material.dart';
import 'package:polygonid_flutter_sdk_example/utils/custom_colors.dart';

class CustomButtonStyle {
  CustomButtonStyle._();

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    elevation: 0,
    enableFeedback: false,
    padding:
        const EdgeInsets.only(top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
    backgroundColor: CustomColors.primaryButton,
    shadowColor: CustomColors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static ButtonStyle primaryButtonStyleSmall = ElevatedButton.styleFrom(
    elevation: 0,
    enableFeedback: false,
    padding:
        const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0, left: 12.0),
    backgroundColor: CustomColors.primaryButton,
    shadowColor: CustomColors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  );

  static ButtonStyle outlinedPrimaryButtonStyle = ElevatedButton.styleFrom(
    elevation: 0,
    enableFeedback: false,
    padding:
        const EdgeInsets.only(top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
    backgroundColor: CustomColors.background,
    shadowColor: CustomColors.transparent,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: CustomColors.primaryButton),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static ButtonStyle disabledPrimaryButtonStyle = ElevatedButton.styleFrom(
    elevation: 0,
    enableFeedback: false,
    padding:
        const EdgeInsets.only(top: 18.0, bottom: 18.0, right: 24.0, left: 24.0),
    backgroundColor: CustomColors.primaryButton.withOpacity(0.5),
    shadowColor: CustomColors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static ButtonStyle iconButtonStyle = ButtonStyle(
    elevation: WidgetStateProperty.all(0.0),
    shape: WidgetStateProperty.all(const CircleBorder()),
    backgroundColor: WidgetStateProperty.all(Colors.white), // <-- Button color
    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return CustomColors.backButtonPressed;
      }
      return null; // <-- Splash color
    }),
  );
}
