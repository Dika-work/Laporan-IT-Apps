import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isLoggedIn;
  final String username;

  AuthState({
    required this.isLoggedIn,
    this.username = '',
  });

  AuthState copyWith({bool? isLoggedIn, String? username}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoggedIn: false));

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ganti dengan URL backend Anda
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<void> login(String username, String password) async {
    try {
      // Kirim request ke backend
      final response = await _dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      // Jika login berhasil
      if (response.statusCode == 200) {
        final data = response.data;
        state = AuthState(isLoggedIn: true, username: data['data']['username']);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Tangani error
      throw Exception('Failed to login: $e');
    }
  }

  // Logout
  void logout() {
    state = AuthState(isLoggedIn: false, username: '');
  }

  // Simpan username jika Remember Me diaktifkan
  Future<void> saveLoginData(String username, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('username', username);
    } else {
      await prefs.remove('username');
    }
  }

  // Ambil username yang disimpan
  Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
