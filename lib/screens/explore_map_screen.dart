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

  final MapController mapController = MapController();

  double currentZoom = 6;

  bool isArabic = false; // 🌍 اللغة

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

  /// 🔎 SEARCH (يدعم عربي + إنجليزي)
  void search(String value) {
    setState(() {
      filtered = places.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final nameAr = (p['name_ar'] ?? '').toString().toLowerCase();

        return name.contains(value.toLowerCase()) ||
            nameAr.contains(value.toLowerCase());
      }).toList();
    });
  }

  /// 🔍 ZOOM IN
  void zoomIn() {
    setState(() {
      if (currentZoom < 18) currentZoom++;
      mapController.move(
        const LatLng(23.5880, 58.3829),
        currentZoom,
      );
    });
  }

  /// 🔍 ZOOM OUT
  void zoomOut() {
    setState(() {
      if (currentZoom > 3) currentZoom--;
      mapController.move(
        const LatLng(23.5880, 58.3829),
        currentZoom,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "الخريطة" : "Map Search"),
        backgroundColor: Colors.teal,
      ),

      body: Stack(
        children: [

          /// 📦 MAIN CONTENT
          Column(
            children: [

              /// 🔍 SEARCH
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  onChanged: search,
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? "ابحث عن مكان..."
                        : "Search places...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              /// 🗺 MAP
              Expanded(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter:
                        const LatLng(23.5880, 58.3829),
                    initialZoom: currentZoom,
                    minZoom: 3,
                    maxZoom: 18,
                  ),

                  children: [
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
                        final lat = double.tryParse(
                            place['latitude'].toString());
                        final lng = double.tryParse(
                            place['longitude'].toString());

                        if (lat == null || lng == null) {
                          return null;
                        }

                        final name = place['name'] ?? '';
                        final nameAr = place['name_ar'] ?? '';

                        final title =
                            isArabic && nameAr != ''
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

          /// 🌍 LANGUAGE BUTTON
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "lang",
              mini: true,
              backgroundColor: Colors.teal,
              onPressed: () {
                setState(() {
                  isArabic = !isArabic;
                });
              },
              child: Text(
                isArabic ? "EN" : "AR",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),

          /// 🔍 ZOOM BUTTONS
          Positioned(
            right: 10,
            bottom: 120,
            child: Column(
              children: [

                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  onPressed: zoomIn,
                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  onPressed: zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}