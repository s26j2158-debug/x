import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final supabase = Supabase.instance.client;

  List<dynamic> favorites = [];
  bool isLoading = true;

  final TextEditingController placeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  @override
  void dispose() {
    placeController.dispose();
    super.dispose();
  }

  Future<void> fetchFavorites() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('favorites')
        .select('id, heritage_places(name)')
        .eq('user_id', user.id);

    setState(() {
      favorites = data;
      isLoading = false;
    });
  }

  Future<void> addFavorite() async {
    placeController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Favorite Place"),
        content: TextField(
          controller: placeController,
          decoration: const InputDecoration(
            hintText: "Enter Heritage Place",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: saveManualFavorite,
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> saveManualFavorite() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    if (placeController.text.isEmpty) return;

    await supabase
        .from('favorites_manual')
        .insert({
      'user_id': user.id,
      'place_name':
          placeController.text.trim(),
    });

    Navigator.pop(context);
    fetchFavorites();
  }

  Future<void> deleteFavorite(
      dynamic favoriteId) async {
    await supabase
        .from('favorites')
        .delete()
        .eq('id', favoriteId);

    fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("My Favorite Places"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    "No favorite heritage places yet",
                    style:
                        TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(12),
                  itemCount:
                      favorites.length,
                  itemBuilder:
                      (context, index) {
                    final place =
                        favorites[index];

                    return Card(
                      elevation: 5,
                      margin:
                          const EdgeInsets.only(
                              bottom: 12),
                      child: ListTile(
                        leading:
                            const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),

                        title: Text(
                          place[
                                  'heritage_places']
                              ['name'],
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        subtitle:
                            const Text(
                          "Saved Place",
                        ),

                        trailing:
                            IconButton(
                          icon: const Icon(
                            Icons.delete,
                          ),
                          onPressed: () {
                            deleteFavorite(
                              place['id'],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: addFavorite,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Favorite",
        ),
        backgroundColor:
            Colors.teal,
      ),
    );
  }
}

