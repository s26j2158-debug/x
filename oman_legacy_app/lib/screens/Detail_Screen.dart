import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'map_screen.dart';

class DetailScreen extends StatefulWidget {
  final dynamic place;

  const DetailScreen({super.key, required this.place});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final supabase = Supabase.instance.client;

  bool isFavorite = false;
  bool loadingFav = true;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        loadingFav = false;
      });
      return;
    }

    final placeId = widget.place['id'];

    final data = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('place_id', placeId)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      isFavorite = data != null;
      loadingFav = false;
    });
  }

  Future<void> toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final placeId = widget.place['id'];

    final existing = await supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('place_id', placeId)
        .maybeSingle();

    if (existing != null) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('place_id', placeId);

      setState(() => isFavorite = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from favorites")),
      );
    } else {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'place_id': placeId,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() => isFavorite = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    final lat = double.tryParse(place['latitude'].toString()) ?? 0;
    final lng = double.tryParse(place['longitude'].toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? ""),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🖼 Image
            Image.network(place['image_url'] ?? ''),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📍 Name
                  Text(
                    place['name'] ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 📝 Description
                  Text(place['description'] ?? ""),

                  const SizedBox(height: 10),

                  /// 💰 PRICE (NEW)
                  Text(
                    "💰 Price: ${place['price'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 5),

                  /// 🕒 OPENING HOURS (NEW)
                  Text(
                    "🕒 Opening Hours: ${place['opening_hours'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  /// ❤️ Favorite button
                  loadingFav
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: toggleFavorite,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(
                            isFavorite
                                ? "Remove from Favorites"
                                : "Add to Favorites",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isFavorite ? Colors.grey : Colors.red,
                          ),
                        ),

                  const SizedBox(height: 10),

                  /// 🗺 Open map button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(
                            latitude: lat,
                            longitude: lng,
                            placeName: place['name'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text("Open Map"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}