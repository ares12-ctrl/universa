import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/data/services/logger_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  Future<void> register() async {
    isLoading.value = true;
    errors.clear();

    final username = usernameController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final password2Val = password2Controller.text;

    // Basic client-side validation
    if (username.isEmpty) errors['username'] = 'هذا الحقل مطلوب';
    if (firstName.isEmpty) errors['first_name'] = 'هذا الحقل مطلوب';
    if (lastName.isEmpty) errors['last_name'] = 'هذا الحقل مطلوب';
    if (email.isEmpty) errors['email'] = 'هذا الحقل مطلوب';
    if (password.isEmpty) errors['password'] = 'هذا الحقل مطلوب';
    if (password2Val.isEmpty) errors['password2'] = 'هذا الحقل مطلوب';

    if (errors.isNotEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final result = await _authService.register(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        password2: password2Val,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        final data = result['data'];
        final access = data['access'];
        final refresh = data['refresh'];

        await _authService.saveTokens(access, refresh);
        
        LoggerService().success('تم إنشاء الحساب بنجاح', title: 'نجاح');
        
        // Use Future.delayed to ensure snackbar shows before navigation 
        // and doesn't conflict with current frame
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/login');
        });
      } else {
        // Handle server-side errors
        final errorData = result['errors'];
        if (errorData is Map) {
          errorData.forEach((key, value) {
            // Check for general errors
            if (key == 'detail' || key == 'general' || key == 'non_field_errors') {
               String msg = value is List ? value.first.toString() : value.toString();
               LoggerService().warning(msg, title: 'تنبيه');
            } else {
              if (value is List) {
                errors[key] = value.first.toString();
              } else {
                errors[key] = value.toString();
              }
            }
          });
        } else {
           LoggerService().error('حدث خطأ غير معروف', title: 'خطأ');
        }
      }
    } catch (e) {
      isLoading.value = false;
      LoggerService().error('حدث خطأ غير متوقع', title: 'خطأ');
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.onClose();
  }
}
