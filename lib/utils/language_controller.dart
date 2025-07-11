// import 'package:get/get.dart';
// import 'package:flutter/material.dart' show Locale;
// import 'package:easy_localization/easy_localization.dart';

// class LanguageController extends GetxController {
//   final _currentLanguage = 'ko'.obs;

//   String get currentLanguage => _currentLanguage.value;

//   void changeLanguage(String languageCode) {
//     _currentLanguage.value = languageCode;
//     Get.updateLocale(Locale(languageCode));
//     EasyLocalization.of(Get.context!)?.setLocale(Locale(languageCode));
//   }
// }

// final languageController = Get.put(LanguageController());
