import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadFile({
    required File file,
    required String bucketName,
  }) async {
    try {
      final String extension = file.path.split('.').last;
      
      final String path = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _supabase.storage.from(bucketName).upload(path, file);

      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  Future<void> deleteFile(String bucketName, String fileUrl) async {
    try {
      final String path = fileUrl.split('/').last;
      await _supabase.storage.from(bucketName).remove([path]);
    } catch (e) {
      print("Delete Error: $e");
    }
  }
}