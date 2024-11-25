import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import '../providers/auth_provider.dart';
import '../providers/remember_me_provider.dart';
import '../utils/theme/app_colors.dart';

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
  bool _hidePass = true;

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
    final rememberMe = ref.watch(rememberMeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/lps.png',
            width: MediaQuery.of(context).size.width * 0.4,
          ),
          const Spacer(),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: CustomSize.md),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: CustomSize.spaceBtwInputFields),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: CustomSize.md),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePass = !_hidePass;
                          });
                        },
                        icon: Icon(
                          _hidePass ? Icons.lock : Icons.lock_open,
                        ),
                      ),
                    ),
                    obscureText: _hidePass,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: CustomSize.sm),
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
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.only(right: CustomSize.md),
                      child: GestureDetector(
                          onTap: () => context.push('/create-user'),
                          child: Text(
                            'buat akun?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.apply(color: AppColors.buttonPrimary),
                          )),
                    )
                  ],
                ),
                const SizedBox(height: CustomSize.spaceBtwItems),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: CustomSize.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                                  await ref
                                      .read(authProvider.notifier)
                                      .saveLoginData(
                                          _usernameController.text, rememberMe);

                                  if (context.mounted) {
                                    floatingSnackBar(
                                      message: 'Login berhasil',
                                      context: context,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: AppColors.white),
                                      duration:
                                          const Duration(milliseconds: 4000),
                                      backgroundColor: AppColors.success,
                                    );
                                    context.go('/home');
                                  }
                                } catch (e) {
                                  print(
                                      'TERJADI ERROR SAAT LOGIN : ${e.toString()}');
                                  if (context.mounted) {
                                    floatingSnackBar(
                                      message:
                                          'Ada yang salah, silahkan coba lagi beberapa saat',
                                      context: context,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: AppColors.white),
                                      duration:
                                          const Duration(milliseconds: 4000),
                                      backgroundColor: AppColors.error,
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const Spacer(),
          const Spacer(),
        ],
      ),
    );
  }
}
