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

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: Text(place['name'] ?? ""),
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🖼 IMAGE
            ClipRRect(
              child: Image.network(
                place['image_url'] ?? '',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.image, size: 60),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 📍 NAME
                  Text(
                    place['name'] ?? "",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 📝 DESCRIPTION
                  Text(
                    place['description'] ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  /// 💰 PRICE CARD
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text("Price"),
                      subtitle: Text(place['price'] ?? "Free"),
                    ),
                  ),

                  /// 🕒 OPENING HOURS
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Opening Hours"),
                      subtitle: Text(place['opening_hours'] ?? "N/A"),
                    ),
                  ),

                  /// 📍 LOCATION INFO
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("Location"),
                      subtitle: Text(
                        "Lat: $lat\nLng: $lng",
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ❤️ FAVORITE
                  loadingFav
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
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
                        ),

                  const SizedBox(height: 10),

                  /// 🗺 MAP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                    ),
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