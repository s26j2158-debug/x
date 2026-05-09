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

  List<dynamic> places = [];
  List<dynamic> filtered = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    final data = await supabase.from('heritage_places').select();

    setState(() {
      places = data;
      filtered = data;
    });
  }

  void search(String value) {
    setState(() {
      filtered = places
          .where((p) =>
              (p['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Search"),
        backgroundColor: Colors.teal,
      ),

      body: Column(
        children: [
          /// 🔍 Search
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

          /// 🗺 Map
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(23.5880, 58.3829),
                initialZoom: 6,
                minZoom: 3,
                maxZoom: 18,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),

              children: [
                /// 🗺️ نفس ستايل الخريطة الموحد
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.oman_legacy_app',
                ),

                MarkerLayer(
                  markers: filtered
                      .where((place) =>
                          place['latitude'] != null &&
                          place['longitude'] != null)
                      .map((place) {
                    final lat =
                        double.tryParse(place['latitude'].toString());
                    final lng =
                        double.tryParse(place['longitude'].toString());

                    if (lat == null || lng == null) {
                      return null;
                    }

                    final name = place['name'] ?? '';
                    final nameAr = place['name_ar'] ?? '';

                    final title = isArabic &&
                            nameAr != null &&
                            nameAr != ''
                        ? nameAr
                        : name;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 45,
                      height: 45,
                      child: Tooltip(
                        message: title,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).whereType<Marker>().toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}