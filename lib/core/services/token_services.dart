import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study_grid/core/services/supabase_service.dart';

Future<void> updateFCMToken({required String userId}) async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();


    if (token != null) {
      await SupabaseService.client
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);

      print("FCM Token updated successfully: $token");
    }
  } catch (e) {
    print("Error updating token: $e");
  }
}
