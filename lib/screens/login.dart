import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laporan/utils/constant/snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/remember_me_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    // Ambil username yang disimpan jika "Remember Me" aktif
    final rememberMe = ref.read(rememberMeProvider);
    if (rememberMe) {
      final username = await ref.read(authProvider.notifier).getSavedUsername();
      if (username != null) {
        _usernameController.text = username;
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snackbar = ref.read(snackbarProvider);
    final rememberMe = ref.watch(rememberMeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      ref
                          .read(rememberMeProvider.notifier)
                          .toggleRememberMe(value!);
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await ref.read(authProvider.notifier).login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );

                            // Simpan username jika "Remember Me" aktif
                            await ref.read(authProvider.notifier).saveLoginData(
                                _usernameController.text, rememberMe);

                            snackbar.showSuccessSnackBar(
                              context,
                              title: 'Success',
                              message: 'Logged in successfully!',
                            );

                            if (context.mounted) {
                              context.go('/home');
                            }
                          } catch (e) {
                            print('TERJADI ERROR SAAT LOGIN : ${e.toString()}');
                            snackbar.showErrorSnackBar(
                              context,
                              title: 'Login Failed',
                              message: e.toString(),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
