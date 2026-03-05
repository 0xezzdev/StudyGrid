import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: "https://pexiueyzeprdnjeluvin.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBleGl1ZXl6ZXByZG5qZWx1dmluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NTMxOTcsImV4cCI6MjA4ODEyOTE5N30.xKYmj7GQfxvGbTQvpD5It2xSV-tApVrnA83Cf2-YbY8",
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}