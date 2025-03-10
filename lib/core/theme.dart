import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

sealed class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.amber,
    subThemesData: const FlexSubThemesData(
      tintedDisabledControls: true,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 15.0,
      filledButtonRadius: 15.0,
      elevatedButtonRadius: 15.0,
      outlinedButtonRadius: 15.0,
      outlinedButtonBorderWidth: 2.0,
      outlinedButtonPressedBorderWidth: 1.5,
      inputDecoratorSchemeColor: SchemeColor.onPrimaryFixed,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 17.0,
      inputDecoratorBorderWidth: 2.0,
      inputDecoratorFocusedBorderWidth: 2.0,
      fabUseShape: true,
      fabRadius: 21.0,
      chipRadius: 18.0,
      chipFontSize: 13,
      chipIconSize: 20,
      chipPadding: EdgeInsetsDirectional.fromSTEB(14, 6, 14, 8),
      cardRadius: 16.0,
      alignedDropdown: true,
      tooltipRadius: 10,
      appBarForegroundSchemeColor: SchemeColor.primary,
      appBarIconSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
      bottomNavigationBarElevation: 6.0,
      bottomNavigationBarSelectedLabelSize: 16,
      bottomNavigationBarUnselectedLabelSize: 14,
      bottomNavigationBarSelectedIconSize: 26,
      bottomNavigationBarUnselectedIconSize: 22,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.amber,
    subThemesData: const FlexSubThemesData(
      tintedDisabledControls: true,
      blendOnColors: true,
      useMaterial3Typography: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 15.0,
      filledButtonRadius: 15.0,
      elevatedButtonRadius: 15.0,
      outlinedButtonRadius: 15.0,
      outlinedButtonBorderWidth: 2.0,
      outlinedButtonPressedBorderWidth: 1.5,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 17.0,
      inputDecoratorBorderWidth: 2.0,
      inputDecoratorFocusedBorderWidth: 2.0,
      fabUseShape: true,
      fabRadius: 21.0,
      chipRadius: 18.0,
      chipFontSize: 13,
      chipIconSize: 20,
      chipPadding: EdgeInsetsDirectional.fromSTEB(14, 6, 14, 8),
      cardRadius: 16.0,
      alignedDropdown: true,
      tooltipRadius: 10,
      appBarForegroundSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
      bottomNavigationBarElevation: 6.0,
      bottomNavigationBarSelectedLabelSize: 16,
      bottomNavigationBarUnselectedLabelSize: 14,
      bottomNavigationBarSelectedIconSize: 26,
      bottomNavigationBarUnselectedIconSize: 22,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
