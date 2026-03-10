import '../../../core/services/supabase_service.dart';

class AuthService {
  final supabase = SupabaseService.client;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone},
    );

    final user = response.user;
    if (user == null) {
      throw Exception("Signup failed");
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

 
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      
      redirectTo: 'studygrid://login-callback', 
    );
  }

  void signOut() {
    supabase.auth.signOut();
  }
}