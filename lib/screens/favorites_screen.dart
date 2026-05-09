import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final supabase = Supabase.instance.client;

  // List to store favorite items
  List<dynamic> favorites = [];

  // Loading state
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // Load favorites when screen starts
    loadFavorites();
  }

  /// Fetch user favorites from Supabase
  Future<void> loadFavorites() async {
    final user = supabase.auth.currentUser;

    // If user is not logged in, stop loading
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    try {
      // Query favorites with related heritage_places data
      final data = await supabase
          .from('favorites')
          .select('''
            id,
            created_at,
            heritage_places (
              id,
              name,
              image_url
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        favorites = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      // Show error message if fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Loading error: $e")),
      );
    }
  }

  /// Delete a favorite item
  Future<void> deleteFav(int id) async {
    try {
      await supabase.from('favorites').delete().eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted successfully")),
      );

      // Reload list after deletion
      loadFavorites();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// Format date to readable format (DD/MM/YYYY)
  String formatDate(String date) {
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.teal,
      ),

      body: loading
          // Loading indicator
          ? const Center(child: CircularProgressIndicator())

          // If user is not logged in
          : user == null
              ? const Center(child: Text("Please log in"))

              // If no favorites found
              : favorites.isEmpty
                  ? const Center(child: Text("No favorites yet"))

                  // Display favorites list
                  : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final item = favorites[index];
                        final place = item['heritage_places'];

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            // Image
                            leading: place['image_url'] != null
                                ? Image.network(
                                    place['image_url'],
                                    width: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image),

                            // Title (place name)
                            title: Text(place['name'] ?? ""),

                            // Subtitle (added date)
                            subtitle: Text(
                              "Added: ${formatDate(item['created_at'])}",
                            ),

                            // Delete button
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => deleteFav(item['id']),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}