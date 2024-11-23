import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rememberMeProvider =
    StateNotifierProvider<RememberMeNotifier, bool>((ref) {
  return RememberMeNotifier();
});

class RememberMeNotifier extends StateNotifier<bool> {
  RememberMeNotifier() : super(false) {
    _loadRememberMe();
  }

  // Load initial value from SharedPreferences
  Future<void> _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('rememberMe') ?? false;
      print('Remember Me State: $state'); // Debug log
    } catch (e) {
      print('Error loading SharedPreferences: $e'); // Debug log
    }
  }

  // Update the value of "Remember Me" and save it
  Future<void> toggleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    state = value;
    await prefs.setBool('rememberMe', value);
  }
}
