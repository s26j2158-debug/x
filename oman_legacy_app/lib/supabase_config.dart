import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://cegteguilnlwstrwojfe.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlZ3RlZ3VpbG5sd3N0cndvamZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5Nzc2NDQsImV4cCI6MjA5MTU1MzY0NH0.0pjmHMqZMZqXl1qY6d4eeNWr5y1yuJLJZOW3Nze2RZo';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}