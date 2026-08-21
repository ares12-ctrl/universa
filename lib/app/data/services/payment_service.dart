import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PaymentService extends GetxService {
  final String _baseUrl = 'https://universa-academy.site';
  final AuthService _authService = Get.find<AuthService>();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>?> checkCoupon(String code, int subjectId) async {
    final url = '$_baseUrl/api/mobile/payments/coupon/check/';
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'code': code,
          'subject_id': subjectId,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        return {'error': error['detail'] ?? 'Invalid coupon'};
      }
    } catch (e) {
      debugPrint('Error checking coupon: $e');
      return {'valid': false, 'error': 'تعذر الاتصال بالخادم، تأكد من الإنترنت'};
    }
  }

  Future<Map<String, dynamic>?> initiatePayment(int subjectId, String? couponCode) async {
    final url = '$_baseUrl/api/mobile/payments/initiate/';
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    final body = {
      'subject_id': subjectId,
      if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        return {'error': error['detail'] ?? 'Failed to initiate payment'};
      }
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      return {'error': 'تعذر الاتصال بالخادم، تأكد من الإنترنت'};
    }
  }

  Future<Map<String, dynamic>?> confirmPayment({
    required int paymentId,
    required String gatewayRef,
    String? payerNote,
    File? receiptImage,
  }) async {
    final url = '$_baseUrl/api/mobile/payments/confirm/$paymentId/';
    final headers = await _getHeaders();
    // Do not set Content-Type manually for MultipartRequest

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      
      request.fields['gateway_ref'] = gatewayRef;
      if (payerNote != null && payerNote.isNotEmpty) {
        request.fields['payer_note'] = payerNote;
      }

      if (receiptImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'receipt_image',
          receiptImage.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint('Confirm payment error: ${response.body}');
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return null;
    }
  }
}
