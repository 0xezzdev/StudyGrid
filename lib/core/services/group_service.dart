import 'dart:io';
import 'package:flutter/material.dart';
import 'package:study_grid/core/colors/app_colors.dart';
import 'package:study_grid/core/components/custom_snackbar.dart';
import 'package:study_grid/core/image/images_const.dart';
import 'package:study_grid/core/services/storage_service.dart';
import 'package:study_grid/core/services/supabase_service.dart';
import 'package:study_grid/feature/groups_page/groups_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//This function is for displaying the group belonging to the current user.
Stream<List<Map<String, dynamic>>> myGroupsStream(String? userId) {
  if (userId == null) return Stream.value([]);

  // 1. الـ Stream هيفضل على جدول الميمبرز عشان ده اللي بيحدد "إنت في أني جروب"
  return SupabaseService.client
      .from('GROUP_MEMBER')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('joined_at', ascending: false)
      .asyncMap((memberships) async {
        final ids = memberships.map((e) => e['group_id']).toList();

        if (ids.isEmpty) return [];

        final groupsDetails = await SupabaseService.client
            .from('GROUP')
            .select('id, name, description, cover_image_url')
            .filter('id', 'in', ids);

        return memberships.map((membership) {
          final group = groupsDetails.firstWhere(
            (g) => g['id'] == membership['group_id'],
            orElse: () => {},
          );

          return {
            'group_id': membership['group_id'],
            'role': membership['role'],
            'group_name': group['name'] ?? 'Unknown',
            'group_desc': group['description'] ?? '',
            'group_img': group['cover_image_url'] ?? '',
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
        final uploadService = StorageService();
        imageUrl = await uploadService.uploadFile(
          file: imageFile,
          bucketName: 'group_avatars',
        );
      }

      // دي الصورة الافتراضية لو عايزين نغيرها ارفعوا الصورة علىة الستورج و حطوا الرابط
      imageUrl ??= ImagesConst.defaultGroupAvatar;
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

Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
  try {
    final response = await SupabaseService.client
        .from('GROUP_MEMBER')
        .select('''
          role,
          profiles:user_id ( id, name, avatar_url )
        ''')
        .eq('group_id', groupId);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print("Error fetching members: $e");
    return [];
  }
}

void updateRole(
  BuildContext context, {
  required String targetUserId,
  required String newRole,
  required int groupId,
  required VoidCallback onRefresh,
  required String userId,
  required String userRole,
}) async {
  try {
    await SupabaseService.client
        .from('GROUP_MEMBER')
        .update({'role': newRole})
        .eq('group_id', groupId)
        .eq('user_id', targetUserId);

    Navigator.pop(context);
    onRefresh();

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'Role updated successfully!',
        icon: Icons.check,
        color: AppColors.greenColor,
      ),
    );

    await SupabaseService.client
        .from('GROUP_MEMBER')
        .update({'role': userRole})
        .eq('user_id', userId)
        .eq('group_id', groupId);
  } catch (e) {
    print("Error updating role: $e");
  }
}

void removeFromGroup(
  BuildContext context, {
  required String targetUserId,
  required int groupId,
  required VoidCallback onRefresh,
  required String userId,
  required String userRole,
}) async {
  try {
    await SupabaseService.client
        .from('GROUP_MEMBER')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', targetUserId);

    onRefresh();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'Member removed successfully!',
        icon: Icons.check,
        color: AppColors.greenColor,
      ),
    );

    await SupabaseService.client
        .from('GROUP_MEMBER')
        .update({'role': userRole})
        .eq('user_id', userId)
        .eq('group_id', groupId);
  } catch (e) {
    print("Error removing member: $e");
  }
}

// Function to update group info (Clean & Modular)
Future<bool> updateGroupDetails({
  required int groupId,
  required String name,
  required String description,
  String? imageUrl,
  required String userId,
  required String userRole,
}) async {
  try {
    final Map<String, dynamic> updateData = {
      'name': name,
      'description': description,
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      updateData['cover_image_url'] = imageUrl;
    }

    final response = await SupabaseService.client
        .from('GROUP')
        .update(updateData)
        .eq('id', groupId)
        .select();

    await SupabaseService.client
        .from('GROUP_MEMBER')
        .update({'role': userRole})
        .eq('user_id', userId)
        .eq('group_id', groupId);

    return response.isNotEmpty;
  } catch (e) {
    print("Error updating group details: $e");
    return false;
  }
}

Future<void> deleteGroup(
  BuildContext context, {
  required int groupId,
  required String userId,
}) async {
  try {
    final response = await SupabaseService.client
        .from('GROUP')
        .delete()
        .eq('id', groupId)
        .select();

    print("Delete Final Check: $response");

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GroupsPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'Group deleted completely!',
        icon: Icons.check,
        color: AppColors.greenColor,
      ),
    );
  } catch (e) {
    print("Delete Error: $e");
  }
}

Future<void> leaveGroup(
  BuildContext context, {
  required String userId,
  required int groupId,
  required int membersCount,
  required String userRole,
}) async {
  try {
    if (membersCount <= 1) {
      await deleteGroup(context, groupId: groupId, userId: userId);
    } else {
      await SupabaseService.client
          .from('GROUP_MEMBER')
          .delete()
          .eq('user_id', userId)
          .eq('group_id', groupId);
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        title: 'Success',
        message: 'You have left the group.',
        color: AppColors.greenColor,
        icon: Icons.check,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GroupsPage()),
      (route) => false,
    );
  } catch (e) {
    print("Error: $e");
  }
}
