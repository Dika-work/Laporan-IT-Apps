import 'package:dio/dio.dart';
import 'package:laporan/models/user_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.3.80.4:8080', // Ubah sesuai dengan alamat server
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Metode untuk membuat user baru
  Future<void> createUser(UserModel user, String password) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'username': user.username,
          'type_user': user.typeUser,
          'password': password, // Kirim password untuk hashing
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
