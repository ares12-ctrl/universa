import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/content_service.dart';
import 'app/data/services/download_service.dart';
import 'app/data/services/payment_service.dart';
import 'app/data/services/ad_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if device is physical (allow simulators in debug mode and handle iOS review safely)
  bool isPhysicalDevice = true;
  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      isPhysicalDevice = iosInfo.isPhysicalDevice;
    }
  } catch (e) {
    debugPrint('Error checking device info: $e');
  }

  // Do not block simulators during debug or on iOS to avoid App Store review rejections
  if (!isPhysicalDevice && !kDebugMode && Platform.isAndroid) {
    runApp(const EmulatorBlockedApp());
    return;
  }

  // Prevent screenshot and screen recording
  await ScreenProtector.preventScreenshotOn();
  // Protect data leakage in app switcher (iOS)
  await ScreenProtector.protectDataLeakageWithColor(const Color(0xFF13111C));

  // Initialize Services
  final authService = Get.put(AuthService(), permanent: true);
  Get.put(ContentService(), permanent: true);
  Get.put(DownloadService(), permanent: true);
  Get.put(PaymentService(), permanent: true);
  await Get.putAsync(() => AdService().init(), permanent: true);

  // Check login status and first time
  final isFirstTime = await authService.isFirstTime();
  final isLoggedIn = await authService.isLoggedIn();

  String initialRoute;
  if (isFirstTime) {
    initialRoute = Routes.ONBOARDING;
  } else {
    initialRoute = isLoggedIn ? Routes.DASHBOARD : Routes.LOGIN;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Website colors from image
    const backgroundColor = Color(0xFF13111C); // Deep Dark Blue/Purple
    const primaryPurple = Color(0xFF8B5CF6); // Bright Purple
    const secondaryCyan = Color(0xFF2DD4BF); // Teal/Cyan
    const surfaceColor = Color(0xFF1E1B2E); // Slightly lighter purple/dark

    return GetMaterialApp(
      title: 'Universa Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryPurple,
          secondary: secondaryCyan,
          surface: surfaceColor,
          background: backgroundColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white.withOpacity(0.9),
          displayColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      defaultTransition: Transition.cupertino,
    );
  }
}

class EmulatorBlockedApp extends StatelessWidget {
  const EmulatorBlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF13111C),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mobile_off,
                  size: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
                Text(
                  'غير مسموح بالتشغيل',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'عذراً، لا يمكن تشغيل هذا التطبيق على المحاكي (Emulator). يجب استخدام جهاز حقيقي.',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text(
                    'خروج',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

