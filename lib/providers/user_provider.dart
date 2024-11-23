import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporan/models/user_model.dart';
import 'api_provider.dart';

// Provider untuk ApiService
final userProvider = Provider<ApiService>((ref) => ApiService());

// Provider untuk Future Data
final userDataProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.read(userProvider).getUsers();
});
