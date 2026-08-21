import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B2E), // Dark Purple/Blue
              Color(0xFF13111C), // Deepest Dark
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_open_rounded,
                            size: 60,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تسجيل الدخول',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'مرحباً بك مجدداً في Universa Academy',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Form Fields
                  _buildStyledField(
                    controller: controller.usernameController,
                    label: 'اسم المستخدم',
                    icon: Icons.person_outline_rounded,
                    primaryColor: primaryColor,
                    errorKey: 'username',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledField(
                    controller: controller.passwordController,
                    label: 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    primaryColor: primaryColor,
                    errorKey: 'password',
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login Button
                  Obx(() {
                    return controller.isLoading.value
                        ? Center(child: CircularProgressIndicator(color: secondaryColor))
                        : Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [secondaryColor, primaryColor],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'تسجيل الدخول',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Register Link
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/register'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.cairo(fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'ليس لديك حساب؟ ',
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                            ),
                            TextSpan(
                              text: 'إنشاء حساب جديد',
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    required String errorKey,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final errorText = this.controller.errors[errorKey];
          final hasError = errorText != null && errorText.isNotEmpty;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: hasError 
                        ? Colors.redAccent 
                        : Colors.white.withOpacity(0.1),
                    width: hasError ? 1.5 : 1.0,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: GoogleFonts.cairo(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      icon, 
                      color: hasError 
                          ? Colors.redAccent.withOpacity(0.7) 
                          : primaryColor.withOpacity(0.7), 
                      size: 22
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'أدخل $label',
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Text(
                    errorText,
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
