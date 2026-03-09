import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_file.dart';

class FileService {
  final _client = Supabase.instance.client;

  String get currentUserId => _client.auth.currentUser?.id ?? '';

  // ── Is current user admin of this group ───────────────────────────────────
  Future<bool> isAdmin(int groupId) async {
    try {
      debugPrint(' Checking admin for groupId: $groupId, userId: $currentUserId');

      final res = await _client
          .from('GROUP')
          .select('created_by, id')
          .eq('id', groupId)
          .single();

      debugPrint(' GROUP row: $res');
      debugPrint(' created_by: ${res['created_by']} == currentUser: $currentUserId → ${res['created_by'] == currentUserId}');

      return res['created_by'] == currentUserId;
    } catch (e) {
      debugPrint(' isAdmin error: $e');
      return false;
    }
  }

  // ── Fetch files for group ─────────────────────────────────────────────────
  Future<List<ClassFile>> fetchFiles(int groupId) async {
    try {
      debugPrint(' Fetching files for groupId: $groupId');

      final res = await _client
          .from('group_files')
          .select('*, users!group_files_uploaded_by_fkey(name)')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      debugPrint(' Files found: ${(res as List).length}');

      return res.map((row) {
        final uploader = row['users'] as Map<String, dynamic>?;
        return ClassFile(
          id:           row['id'].toString(),
          name:         row['name'],
          sizeMB:       (row['size_mb'] as num).toDouble(),
          uploadedAt:   DateTime.parse(row['created_at']),
          uploaderName: uploader?['name'] ?? 'Unknown',
          type:         row['type'],
          url:          row['url'],
          storagePath:  row['storage_path'],
        );
      }).toList();
    } catch (e) {
      debugPrint(' fetchFiles error: $e');
      return [];
    }
  }

  // ── Upload file ───────────────────────────────────────────────────────────
  Future<void> uploadFile(int groupId, File file, String fileName, String ext) async {
    try {
      // Sanitize filename — remove non-ASCII, replace spaces with underscores
      final sanitized = fileName
          .replaceAll(RegExp(r'[^\x00-\x7F]'), '')   // remove Arabic/non-ASCII
          .replaceAll(RegExp(r'\s+'), '_')             // spaces → underscores
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '') // remove special chars
          .trim();

      // Fallback if name becomes empty after sanitization
      final safeName = sanitized.isEmpty
          ? '${DateTime.now().millisecondsSinceEpoch}.$ext'
          : sanitized;

      final path = '$groupId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final bytes = await file.readAsBytes();

      debugPrint(' Uploading as: $path');

      await _client.storage.from('group_files').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: _mimeType(ext)),
      );

      final url = _client.storage.from('group_files').getPublicUrl(path);
      final sizeMB = bytes.length / (1024 * 1024);

      // Store original Arabic name in DB for display, safe path for storage
      await _client.from('group_files').insert({
        'group_id':     groupId,
        'name':         fileName,   // original name shown to user
        'size_mb':      sizeMB,
        'type':         ext,
        'url':          url,
        'storage_path': path,       // sanitized path used in storage
        'uploaded_by':  currentUserId,
      });

      debugPrint('File uploaded: $fileName');
    } catch (e) {
      debugPrint('uploadFile error: $e');
      rethrow;
    }
  }

  // ── Delete file ───────────────────────────────────────────────────────────
  Future<void> deleteFile(ClassFile file) async {
    try {
      await _client.storage.from('group_files').remove([file.storagePath!]);
      await _client.from('group_files').delete().eq('id', int.parse(file.id));
    } catch (e) {
      debugPrint(' deleteFile error: $e');
      rethrow;
    }
  }

  String _mimeType(String ext) => switch (ext.toLowerCase()) {
    'pdf'  => 'application/pdf',
    'doc'  => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'ppt'  => 'application/vnd.ms-powerpoint',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    _      => 'application/octet-stream',
  };
  Stream<List<ClassFile>> filesStream(int groupId) async* {
    while (true) {
      try {
        yield await fetchFiles(groupId);
      } catch (_) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}