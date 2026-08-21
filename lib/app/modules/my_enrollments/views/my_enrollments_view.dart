import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/my_enrollments_controller.dart';
import '../../../routes/app_pages.dart';

class MyEnrollmentsView extends GetView<MyEnrollmentsController> {
  const MyEnrollmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('موادي النشطة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.enrollments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book_rounded, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'لا توجد مواد نشطة حالياً',
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchEnrollments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = controller.enrollments[index];
              final subject = enrollment.subject;
              
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.SUBJECT_DETAILS, arguments: subject.slug),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image and Progress Overlay
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Hero(
                                tag: 'subject_${subject.id}',
                                child: Image.network(
                                  subject.coverImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[900], child: const Icon(Icons.image_not_supported)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${enrollment.progressPercent}% مكتمل',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: Colors.white54),
                                  const SizedBox(width: 4),
                                  Text(
                                    subject.instructor.fullName,
                                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: double.tryParse(enrollment.progressPercent)! / 100,
                                  backgroundColor: Colors.white10,
                                  color: theme.colorScheme.primary,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Expiry Date
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.orangeAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ينتهي في: ${_formatDate(enrollment.expiresAt)}',
                                    style: GoogleFonts.cairo(
                                      color: Colors.orangeAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
