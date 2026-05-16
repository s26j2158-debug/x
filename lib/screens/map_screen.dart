import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeName;
  final String? placeNameAr;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    this.placeNameAr,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late final MapController mapController;
  double currentZoom = 14;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {

    final LatLng point = LatLng(widget.latitude, widget.longitude);
    final title = widget.placeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),

      body: Stack(
        children: [

          /// 🗺 MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: point,
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
                markers: [
                  Marker(
                    point: point,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 45,
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
                  onPressed: () {
                    setState(() {
                      currentZoom++;
                      mapController.move(point, currentZoom);
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
                      mapController.move(point, currentZoom);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          /// 🧭 Info Card
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: const [
                    Icon(Icons.place, color: Colors.teal),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Location Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}