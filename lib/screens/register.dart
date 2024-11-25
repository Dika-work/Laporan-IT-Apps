import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporan/models/user_model.dart';
import 'package:laporan/providers/user_provider.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final TextEditingController _typeUserController = TextEditingController();
  String? _selectedTypeUser;
  final List<String> _typeUserOptions = [
    'Admin',
    'User',
    'Guest'
  ]; // Opsi dropdown

  final _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _hidePass = true;
  bool _hideConfirmPass = true;

  // RegExp untuk validasi password
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  @override
  void dispose() {
    _usernameController.dispose();
    _typeUserController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: CustomSize.spaceBtwSections),
            Image.asset(
              'assets/images/lps.png',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
            const SizedBox(height: CustomSize.spaceBtwSections),
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username Field
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
                  // Type User Dropdown
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: CustomSize.md),
                    child: DropdownButtonFormField2(
                      value: _selectedTypeUser,
                      items: _typeUserOptions.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type), // Tampilan dalam dropdown
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTypeUser = newValue!;
                          _typeUserController.text = newValue;
                        });
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _typeUserOptions.map((String type) {
                          return Text(
                            type,
                            style: const TextStyle(fontSize: 16.0),
                          );
                        }).toList();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Type User',
                        border: OutlineInputBorder(),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.zero, // Item dropdown tanpa padding
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Type User is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: CustomSize.spaceBtwInputFields),
                  // Password Field
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
                        // Daftar kriteria yang belum terpenuhi
                        List<String> errors = [];

                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }

                        // Tambahkan pesan error untuk kriteria yang belum terpenuhi
                        if (value.length < 8) {
                          errors.add('- At least 8 characters');
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          errors.add('- At least 1 uppercase letter');
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          errors.add('- At least 1 number');
                        }
                        if (!value.contains(RegExp(r'[@$!%*?&]'))) {
                          errors
                              .add('- At least 1 special character (@\$!%*?&)');
                        }

                        // Jika tidak ada error, return null (valid)
                        if (errors.isEmpty) {
                          return null;
                        }

                        // Gabungkan error yang belum terpenuhi menjadi satu string
                        return 'Password must have:\n${errors.join('\n')}';
                      },
                    ),
                  ),

                  const SizedBox(height: CustomSize.spaceBtwInputFields),

                  // Confirm Password Field
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: CustomSize.md),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPass = !_hideConfirmPass;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPass ? Icons.lock : Icons.lock_open,
                          ),
                        ),
                      ),
                      obscureText: _hideConfirmPass,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm Password is required';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: CustomSize.spaceBtwItems),
                  // Submit Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
                                  final user = UserModel(
                                    username: _usernameController.text,
                                    typeUser: _typeUserController.text,
                                    usernameHash:
                                        '', // Tidak dikirim ke backend
                                  );

                                  try {
                                    await ref.read(userProvider).createUser(
                                        user, _passwordController.text);
                                    if (context.mounted) {
                                      floatingSnackBar(
                                        message: 'Berhasil membuat akun baru',
                                        context: context,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(color: AppColors.white),
                                        duration:
                                            const Duration(milliseconds: 4000),
                                        backgroundColor: AppColors.success,
                                      );
                                      Navigator.pop(context);
                                      ref.invalidate(userDataProvider);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      floatingSnackBar(
                                        message: 'Kesalahan : $e',
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
                              child: const Text('Create User'),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
