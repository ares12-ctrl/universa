import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/data/services/logger_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  Future<void> login() async {
    isLoading.value = true;
    errors.clear();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Basic client-side validation
    if (username.isEmpty) errors['username'] = 'هذا الحقل مطلوب';
    if (password.isEmpty) errors['password'] = 'هذا الحقل مطلوب';

    if (errors.isNotEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        final data = result['data'];
        final access = data['access'];
        final refresh = data['refresh'];

        await _authService.saveTokens(access, refresh);
        await _authService.saveUsername(username);

        LoggerService().success('تم تسجيل الدخول بنجاح', title: 'نجاح');

        Get.offAllNamed('/dashboard');
      } else {
        // Handle server-side errors
        final errorData = result['errors'];
        if (errorData is Map) {
          errorData.forEach((key, value) {
            if (key == 'detail' || key == 'general' || key == 'non_field_errors' || (!['username', 'password'].contains(key))) {
               String msg = value is List ? value.first.toString() : value.toString();
               // If it's a specific field error not in the form (like device_id), show it clearly
               if (!['detail', 'general', 'non_field_errors'].contains(key)) {
                 msg = '$key: $msg';
               }
               
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
    passwordController.dispose();
    super.onClose();
  }
}
