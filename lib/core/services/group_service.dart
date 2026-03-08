import 'dart:io';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/core/services/upload_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//This function is for displaying the group belonging to the current user.
Stream<List<Map<String, dynamic>>> myGroupsStream(String? userId) {
  if (userId == null) return Stream.value([]);
  return SupabaseService.client
      .from('GROUP_MEMBER')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId!)
      .asyncMap((data) async {
        final ids = data.map((e) => e['group_id']).toList();
        final groupsDetails = await SupabaseService.client
            .from('GROUP')
            .select('id, name, description, cover_image_url')
            .filter('id', 'in', ids);
        return data.map((membership) {
          final details = groupsDetails.firstWhere(
            (g) => g['id'] == membership['group_id'],
          );
          return {
            ...membership,
            'group_name': details['name'],
            'group_desc': details['description'],
            'group_img': details['cover_image_url'],
            'group_id': details['id'],
          };
        }).toList();
      });
}

Future<int> getGroupMembersCount(String groupId) async {
  try {
    final countResponse = await SupabaseService.client
        .from('GROUP_MEMBER')
        .select('user_id')
        .eq('group_id', groupId)
        .count(CountOption.exact);

    return countResponse.count;
  } catch (e) {
    return 0;
  }
}

Future<PostgrestMap?> getGroupDetails(int groupId) async {
  try {
    final response = await SupabaseService.client
        .from('GROUP')
        .select()
        .eq('id', groupId)
        .single();
    return response;
  } catch (e) {
    print("Error fetching group details: $e");
    return null;
  }
}

// من اسمها واضح بتعمل ايه مش لازم اشرح الصراحة انا اكسل من اني اعمل كدة @ezz
Future<void> createNewGroup({
  required String name,
  required String description,
  required String userId,
  File? imageFile,
}) async {
  if (userId != null) {
    try {
      String? imageUrl;
      // هنا برفع الصورة للستورج عشان اخد منها الرابط اخزنه في جدول المجموعات
      if (imageFile != null) {
        final uploadService = UploadImage();
        imageUrl = await uploadService.uploadImage(imageFile, 'group_avatars');
      }

      // دي الصورة الافتراضية لو عايزين نغيرها ارفعوا الصورة علىة الستورج و حطوا الرابط
      imageUrl ??=
          'https://pexiueyzeprdnjeluvin.supabase.co/storage/v1/object/public/group_avatars/def_group.jpg';

      // هنا بقا بخزن في جدول المجموعات
      final groupResponse = await SupabaseService.client
          .from('GROUP')
          .insert({
            'name': name,
            'description': description,
            'created_by': userId,
            'cover_image_url': imageUrl,
          })
          .select()
          .single();

      final groupId = groupResponse['id'];

      // هنا بخزن في البردج المفروض انتم فاهمين كده ف مش هشرح
      await SupabaseService.client.from('GROUP_MEMBER').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'admin',
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}

// برضه اسمها واضح والله مش لازم اشرح
Future<String?> joinGroup({
  required String inviteCode,
  required String userId,
}) async {
  try {
    // هنا بتشك الكود موجود ولا لا
    final groupData = await SupabaseService.client
        .from('GROUP')
        .select('id')
        .eq('invite_code', inviteCode)
        .maybeSingle();

    if (groupData == null) {
      return "Invite Code didnt exist";
    }

    final groupId = groupData['id'];

    //بتشك هل موجود في الجروب قبل كده ولا لا
    final alreadyMember = await SupabaseService.client
        .from('GROUP_MEMBER')
        .select()
        .eq('group_id', groupId)
        .eq('user_id', userId)
        .maybeSingle();

    if (alreadyMember != null) {
      return "you are already in the group";
    }

    // نضيف للجروب
    await SupabaseService.client.from('GROUP_MEMBER').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'member',
    });

    return null;
  } catch (e) {
    return "Error: $e";
  }
}

// معرفه roule المستخدم في الجروب
Future<String?> getUserRoleInGroup(String userId, String groupId) async {
  try {
    final response = await SupabaseService.client
        .from('GROUP_MEMBER')
        .select('role')
        .eq('user_id', userId)
        .eq('group_id', groupId)
        .maybeSingle();
    return response != null ? response['role'] : null;
  } catch (e) {
    print("Error fetching user role: $e");
    return null;
  }
}


