import 'package:study_grid/feature/folders_page/models/folders_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FolderRepository {
  final _supabase = Supabase.instance.client;

  Future<Folder> createFolder({
    required String title,
    required int? groupId,
    required String scope,
    required String createdBy,
  }) async {
    final response = await _supabase
        .from('folders')
        .insert({
          'group_id': groupId,
          'title': title,
          'scope': scope,
          'created_by': createdBy,
        })
        .select()
        .single();

    return Folder.fromJson(response);
  }

  Future<List<Folder>> getGroupFolders({required int groupId}) async {
    final response = await _supabase
        .from('folders')
        .select()
        .eq('group_id', groupId);

    return (response as List).map((e) => Folder.fromJson(e)).toList();
  }

  Future<List<Folder>> getPersonalFolders({required String userId}) async {
    final response = await _supabase
        .from('folders')
        .select()
        .eq('created_by', userId)
        .eq('scope', 'personal');
    return (response as List).map((e) => Folder.fromJson(e)).toList();
  }

  Future<void> deleteFolder({required String folderId}) async {
    await _supabase.from('folders').delete().eq('id', folderId);
  }
}
