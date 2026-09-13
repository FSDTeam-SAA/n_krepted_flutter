import 'package:flutter/material.dart';

class AppLanguageProvider with ChangeNotifier {
  Locale get locale => const Locale('de');
  bool get isGerman => true;
  String get languageName => 'Deutsch';

  String text(String german, [String? _]) => german;
}
