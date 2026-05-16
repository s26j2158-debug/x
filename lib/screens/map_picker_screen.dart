import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {

  /// 📍 Default location (Oman)
  LatLng selectedLocation = LatLng(23.5880, 58.3829);

  final TextEditingController searchController = TextEditingController();

  final MapController mapController = MapController();

  double currentZoom = 10;

  /// 🔎 SEARCH FUNCTION
  Future<void> searchPlace(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?format=json&q=$query",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final first = data[0];

          final lat = double.parse(first['lat']);
          final lon = double.parse(first['lon']);

          setState(() {
            selectedLocation = LatLng(lat, lon);
            currentZoom = 15;
          });

          /// 🚀 تحريك الخريطة للموقع + تكبير
          mapController.move(
            LatLng(lat, lon),
            15,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Search failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: Colors.teal,
      ),

      body: Stack(
        children: [

          /// 🗺 MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: currentZoom,

              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),

            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.oman_legacy_app',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 80,
                    height: 80,
                    child: AnimatedScale(
                      scale: 1.2,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// 🔍 SEARCH BAR
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search place (e.g. Muscat)",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
                onSubmitted: searchPlace,
              ),
            ),
          ),

          /// 🔍 ZOOM BUTTONS
          Positioned(
            right: 10,
            bottom: 200,
            child: Column(
              children: [

                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  onPressed: () {
                    setState(() {
                      currentZoom++;
                      mapController.move(selectedLocation, currentZoom);
                    });
                  },
                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 10),

                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  onPressed: () {
                    setState(() {
                      currentZoom--;
                      mapController.move(selectedLocation, currentZoom);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          /// 📌 Bottom Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    "Latitude: ${selectedLocation.latitude}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Longitude: ${selectedLocation.longitude}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  /// ✅ Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, {
                          'latitude': selectedLocation.latitude,
                          'longitude': selectedLocation.longitude,
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Confirm Location"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}