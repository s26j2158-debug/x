import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final String appVersion = "1.0.0";

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Oman Legacy"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Logo
            CircleAvatar(
              radius: 85,
              backgroundImage: const AssetImage("images/logo.png"),
              backgroundColor: Colors.grey.shade200,
            ),

            const SizedBox(height: 20),

            // Main Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  const Text(
                    "Oman Legacy",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Version $appVersion",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Oman Legacy is a smart tourism application that helps users explore famous forts, castles, and historical landmarks in Oman.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Users can browse heritage places, view details, save favorites, use maps, and write reviews using Supabase cloud database.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.teal),
                    title: const Text("Logged User"),
                    subtitle: Text(
                      user?.email ?? "Guest User",
                    ),
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(Icons.school, color: Colors.teal),
                    title: Text("Developed For"),
                    subtitle: Text("CSSE3203 Mobile Application Development"),
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(Icons.flag, color: Colors.teal),
                    title: Text("Supports"),
                    subtitle: Text("Oman Vision 2040"),
                  ),

                  const Divider(),

                  const ListTile(
                    leading: Icon(Icons.travel_explore, color: Colors.teal),
                    title: Text("Technology"),
                    subtitle: Text("Flutter + Supabase"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "© 2026 Oman Legacy App. All rights reserved.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

