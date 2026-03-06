import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

// ده كلاس مسؤول عن رفع الصور في الستورج في احتمال اغيره مستقبلا واخليه مسؤول عن اي عملية رفع في الستورج
class UploadImage {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadImage(File imageFile, String bucketName) async {
    try {
      //هنا يا شباب بعمل اسم للملف على الستورج بتاعنا على سوبا بيز
      final String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _supabase.storage.from(bucketName).upload(fileName, imageFile);

      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print("ُError: $e");
      return null;
    }
  }
}
