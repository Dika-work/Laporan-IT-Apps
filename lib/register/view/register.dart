import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporan/utils/constant/custom_size.dart';
import 'package:laporan/utils/theme/app_colors.dart';

import '../controller/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: CustomSize.spaceBtwSections),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text("Take a Photo"),
                          onTap: () {
                            Get.back();
                            controller.pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text("Choose from Gallery"),
                          onTap: () {
                            Get.back();
                            controller.pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.5,
                          color: AppColors.borderSecondary,
                        ),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(5, 5),
                          ),
                        ],
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: controller.selectedImage != null
                            ? FileImage(controller
                                .selectedImage!) // Gambar yang dipilih
                            : const AssetImage('assets/images/lps.png')
                                as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 3,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: AppColors.primary,
                        ),
                        child: Icon(
                          controller.selectedImage != null
                              ? Icons.delete
                              : Icons.camera_alt,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CustomSize.spaceBtwSections),
              // Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // Username Field
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: CustomSize.md),
                      child: TextFormField(
                        controller: controller.usernameC,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
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
                      child: Obx(() => DropdownButtonFormField2<String>(
                            value: controller.selectedTypeUser.value.isNotEmpty
                                ? controller.selectedTypeUser.value
                                : null, // Pastikan value null jika belum ada pilihan
                            items:
                                controller.typeUserOptions.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type), // Tampilan dalam dropdown
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.selectedTypeUser.value = newValue;
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Type User',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Type User is required';
                              }
                              return null;
                            },
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
                              padding: EdgeInsets
                                  .zero, // Item dropdown tanpa padding
                            ),
                          )),
                    ),
                    const SizedBox(height: CustomSize.spaceBtwInputFields),
                    // Password Field
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: CustomSize.md),
                        child: Obx(
                          () => TextFormField(
                            controller: controller.passC,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  controller.obscureText.value =
                                      !(controller.obscureText.value);
                                },
                                icon: Icon(
                                  (controller.obscureText.value != false)
                                      ? Icons.lock
                                      : Icons.lock_open,
                                ),
                              ),
                            ),
                            obscureText: controller.obscureText.value,
                            validator: (value) {
                              List<String> errors = [];

                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }

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
                                errors.add(
                                    '- At least 1 special character (@\$!%*?&)');
                              }

                              if (errors.isEmpty) {
                                return null;
                              }

                              return 'Password must have:\n${errors.join('\n')}';
                            },
                          ),
                        )),

                    const SizedBox(height: CustomSize.spaceBtwInputFields),
                    // Confirm Password Field
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: CustomSize.md),
                      child: TextFormField(
                        controller: controller.confirmPassC,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.confirmObscureText.value =
                                  !(controller.confirmObscureText.value);
                            },
                            icon: Icon(
                              (controller.confirmObscureText.value != false)
                                  ? Icons.lock
                                  : Icons.lock_open,
                            ),
                          ),
                        ),
                        obscureText: controller.confirmObscureText.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm Password is required';
                          }
                          if (value != controller.confirmPassC.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: CustomSize.defaultSpace),
                    // Submit Button
                    Obx(
                      () => controller.isLoading.isTrue
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: CustomSize.md),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.registerEmailandPassword(),
                                  child: const Text('Create User'),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
