import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final supabase = Supabase.instance.client;

  List<dynamic> places = [];
  List<dynamic> filteredPlaces = [];

  bool isLoading = true;

  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Fort",
    "Castle",
    "Historical",
  ];

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  /// 📥 Load heritage places (FIXED QUERY)
  Future<void> loadPlaces() async {
    final data = await supabase
        .from('heritage_places')
        .select('''
          id,
          name,
          description,
          image_url,
          category,
          price,
          opening_hours,
          latitude,
          longitude
        ''');

    setState(() {
      places = data;
      filteredPlaces = data;
      isLoading = false;
    });
  }

  /// ⭐ Add place to favorites
  Future<void> addToFavorites(int placeId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first")),
      );
      return;
    }

    try {
      final existing = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('place_id', placeId);

      if (existing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already added to favorites")),
        );
        return;
      }

      await supabase.from('favorites').insert({
        'user_id': user.id,
        'place_id': placeId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// 🔍 Filter places
  void filterPlaces() {
    setState(() {
      filteredPlaces = places.where((place) {
        final name = (place['name'] ?? "").toString().toLowerCase();
        final category = (place['category'] ?? "").toString();

        final matchSearch = name.contains(searchQuery.toLowerCase());

        final matchCategory =
            selectedCategory == "All" ? true : category == selectedCategory;

        return matchSearch && matchCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Heritage"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          /// 🔍 Search
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                filterPlaces();
              },
              decoration: InputDecoration(
                hintText: "Search places...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🏷 Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat;
                      filterPlaces();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == cat
                          ? Colors.teal
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selectedCategory == cat
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// 📦 List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPlaces.isEmpty
                    ? const Center(child: Text("No places found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          final place = filteredPlaces[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(place: place),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    place['image_url'] ?? '',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    /// ⭐ Favorite button
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.star_border,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              addToFavorites(place['id']),
                                        ),
                                      ),
                                    ),

                                    /// 📍 Name + Price + Opening Hours (FIXED)
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              place['name'] ?? "",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 5),

                                            Text(
                                              "Price: ${place['price'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),

                                            Text(
                                              "Open: ${place['opening_hours'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}