import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final supabase = Supabase.instance.client;

  // All heritage places
  List<dynamic> places = [];

  // Filtered places based on search
  List<dynamic> filtered = [];

  // Search controller
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data on screen start
    loadPlaces();
  }

  /// 📥 Load heritage places from Supabase
  Future<void> loadPlaces() async {
    final data = await supabase.from('heritage_places').select();

    setState(() {
      places = data;
      filtered = data;
    });
  }

  /// 🔍 Search places by name
  void search(String value) {
    setState(() {
      filtered = places
          .where((p) => p['name']
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Search"),
        backgroundColor: Colors.teal,
      ),

      body: Column(
        children: [
          /// 🔍 Search field
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: search,
              decoration: InputDecoration(
                hintText: "Search places...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// 🗺 Map view
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(23.5880, 58.3829), // Oman center
                initialZoom: 6,
              ),
              children: [
                /// Map tiles (OpenStreetMap)
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),

                /// Markers for places
                MarkerLayer(
                  markers: filtered.map((place) {
                    final lat =
                        double.tryParse(place['latitude'].toString()) ?? 0;
                    final lng =
                        double.tryParse(place['longitude'].toString()) ?? 0;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: place['name'],
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}