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

  /// 📥 Load places
  Future<void> loadPlaces() async {

    final data = await supabase
        .from('heritage_places')
        .select();

    setState(() {
      places = data;
      filteredPlaces = data;
      isLoading = false;
    });
  }

  /// ⭐ Favorites
  Future<void> addToFavorites(int placeId) async {

    final user = supabase.auth.currentUser;

    if (user == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login first"),
        ),
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
          const SnackBar(
            content: Text("Already added"),
          ),
        );

        return;
      }

      await supabase.from('favorites').insert({
        'user_id': user.id,
        'place_id': placeId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to favorites"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  /// 🗑 Delete place
  Future<void> deletePlace(int id) async {

    try {

      await supabase
          .from('heritage_places')
          .delete()
          .eq('id', id);

      await loadPlaces();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Place deleted"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Delete failed: $e",
          ),
        ),
      );
    }
  }

  /// 🔍 Filter
  void filterPlaces() {

    setState(() {

      filteredPlaces = places.where((place) {

        final name =
            (place['name'] ?? "")
                .toString()
                .toLowerCase();

        final category =
            (place['category'] ?? "")
                .toString();

        final matchSearch =
            name.contains(
              searchQuery.toLowerCase(),
            );

        final matchCategory =
            selectedCategory == "All"
                ? true
                : category == selectedCategory;

        return matchSearch &&
            matchCategory;

      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    final currentUser =
        supabase.auth.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Explore Heritage",
        ),
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

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,
                fillColor: Colors.grey[200],

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(25),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🏷 Categories
          SizedBox(

            height: 50,

            child: ListView.builder(

              scrollDirection:
                  Axis.horizontal,

              itemCount:
                  categories.length,

              itemBuilder:
                  (context, index) {

                final cat =
                    categories[index];

                return GestureDetector(

                  onTap: () {

                    setState(() {
                      selectedCategory =
                          cat;

                      filterPlaces();
                    });
                  },

                  child: Container(

                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(

                      color:
                          selectedCategory ==
                                  cat
                              ? Colors.teal
                              : Colors.grey[300],

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(

                      cat,

                      style: TextStyle(
                        color:
                            selectedCategory ==
                                    cat
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// 📦 Places
          Expanded(

            child: isLoading

                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )

                : filteredPlaces.isEmpty

                    ? const Center(
                        child:
                            Text(
                          "No places found",
                        ),
                      )

                    : ListView.builder(

                        padding:
                            const EdgeInsets.all(
                          10,
                        ),

                        itemCount:
                            filteredPlaces.length,

                        itemBuilder:
                            (context, index) {

                          final place =
                              filteredPlaces[index];

                          final isMyPlace =
                              place['user_id'] ==
                                  currentUser?.id;

                          return GestureDetector(

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      DetailScreen(
                                    place: place,
                                  ),
                                ),
                              );
                            },

                            child: Container(

                              margin:
                                  const EdgeInsets.only(
                                bottom: 15,
                              ),

                              height: 220,

                              decoration:
                                  BoxDecoration(

                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),

                                image:
                                    DecorationImage(

                                  image: place[
                                              'image_url']
                                          .toString()
                                          .startsWith(
                                            'http',
                                          )

                                      ? NetworkImage(
                                          place[
                                              'image_url'],
                                        )

                                      : AssetImage(
                                          place[
                                              'image_url'],
                                        ) as ImageProvider,

                                  fit:
                                      BoxFit.cover,
                                ),
                              ),

                              child: Container(

                                decoration:
                                    BoxDecoration(

                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),

                                  gradient:
                                      LinearGradient(

                                    begin:
                                        Alignment
                                            .bottomCenter,

                                    end:
                                        Alignment
                                            .topCenter,

                                    colors: [

                                      Colors.black
                                          .withOpacity(
                                        0.7,
                                      ),

                                      Colors
                                          .transparent,
                                    ],
                                  ),
                                ),

                                child: Stack(

                                  children: [

                                    /// ⭐ Favorite
                                    Positioned(

                                      top: 10,
                                      right: 10,

                                      child:
                                          Container(

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              Colors.black
                                                  .withOpacity(
                                            0.5,
                                          ),

                                          shape:
                                              BoxShape
                                                  .circle,
                                        ),

                                        child:
                                            IconButton(

                                          icon:
                                              const Icon(
                                            Icons
                                                .star_border,

                                            color:
                                                Colors
                                                    .white,
                                          ),

                                          onPressed:
                                              () =>
                                                  addToFavorites(
                                            place[
                                                'id'],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// 🗑 Delete
                                    if (isMyPlace)

                                      Positioned(

                                        top: 10,
                                        left: 10,

                                        child:
                                            Container(

                                          decoration:
                                              BoxDecoration(

                                            color:
                                                Colors.red
                                                    .withOpacity(
                                              0.8,
                                            ),

                                            shape:
                                                BoxShape
                                                    .circle,
                                          ),

                                          child:
                                              IconButton(

                                            icon:
                                                const Icon(
                                              Icons
                                                  .delete,

                                              color:
                                                  Colors
                                                      .white,
                                            ),

                                            onPressed:
                                                () async {

                                              final confirm =
                                                  await showDialog(

                                                context:
                                                    context,

                                                builder:
                                                    (_) =>
                                                        AlertDialog(

                                                  title:
                                                      const Text(
                                                    "Delete Place",
                                                  ),

                                                  content:
                                                      const Text(
                                                    "Are you sure you want to delete this place?",
                                                  ),

                                                  actions: [

                                                    TextButton(

                                                      onPressed:
                                                          () {

                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        );
                                                      },

                                                      child:
                                                          const Text(
                                                        "Cancel",
                                                      ),
                                                    ),

                                                    TextButton(

                                                      onPressed:
                                                          () {

                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                      },

                                                      child:
                                                          const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm ==
                                                  true) {

                                                deletePlace(
                                                  place[
                                                      'id'],
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),

                                    /// 📍 Text
                                    Padding(

                                      padding:
                                          const EdgeInsets.all(
                                        12,
                                      ),

                                      child:
                                          Align(

                                        alignment:
                                            Alignment
                                                .bottomLeft,

                                        child:
                                            Column(

                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          mainAxisSize:
                                              MainAxisSize
                                                  .min,

                                          children: [

                                            Text(

                                              place['name'] ??
                                                  "",

                                              style:
                                                  const TextStyle(

                                                color:
                                                    Colors
                                                        .white,

                                                fontSize:
                                                    22,

                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  5,
                                            ),

                                            Text(

                                              "Category: ${place['category'] ?? ''}",

                                              style:
                                                  const TextStyle(

                                                color:
                                                    Colors
                                                        .white70,

                                                fontSize:
                                                    14,
                                              ),
                                            ),

                                            Text(

                                              "Open: ${place['opening_hours'] ?? 'N/A'}",

                                              style:
                                                  const TextStyle(

                                                color:
                                                    Colors
                                                        .white70,

                                                fontSize:
                                                    14,
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