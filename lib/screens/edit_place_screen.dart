import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'map_picker_screen.dart';

class EditPlaceScreen extends StatefulWidget {

  final dynamic place;

  const EditPlaceScreen({
    super.key,
    required this.place,
  });

  @override
  State<EditPlaceScreen> createState() =>
      _EditPlaceScreenState();
}

class _EditPlaceScreenState
    extends State<EditPlaceScreen> {

  final supabase =
      Supabase.instance.client;

  late TextEditingController
      nameController;

  late TextEditingController
      descriptionController;

  late TextEditingController
      imageUrlController;

  bool isLoading = false;

  late String selectedCategory;

  late String selectedOpeningHours;

  late String selectedPrice;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    final place = widget.place;

    nameController =
        TextEditingController(
      text: place['name'] ?? "",
    );

    descriptionController =
        TextEditingController(
      text: place['description'] ?? "",
    );

    imageUrlController =
        TextEditingController(
      text: place['image_url'] ?? "",
    );

    selectedCategory =
        place['category'] ?? "Fort";

    selectedOpeningHours =
        place['opening_hours'] ??
            "8 AM - 4 PM";

    selectedPrice =
        place['price'] ?? "Free";

    latitude =
        double.tryParse(
      place['latitude'].toString(),
    );

    longitude =
        double.tryParse(
      place['longitude'].toString(),
    );
  }

  /// ✏️ Update Place
  Future<void> updatePlace() async {

    setState(() {
      isLoading = true;
    });

    try {

      await supabase
          .from('heritage_places')
          .update({

        'name':
            nameController.text,

        'description':
            descriptionController.text,

        'image_url':
            imageUrlController.text,

        'category':
            selectedCategory,

        'opening_hours':
            selectedOpeningHours,

        'price':
            selectedPrice,

        'latitude':
            latitude,

        'longitude':
            longitude,

      }).eq(
        'id',
        widget.place['id'],
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Place updated successfully",
          ),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// 📝 Field
  Widget buildField(
    String label,
    TextEditingController controller,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextField(

        controller: controller,

        onChanged: (_) {
          setState(() {});
        },

        decoration: InputDecoration(

          labelText: label,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              15,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[100],

      appBar: AppBar(

        title: const Text(
          "Edit Place",
        ),

        backgroundColor:
            Colors.teal,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            /// 🖼 Image Preview
            Container(

              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(

                color: Colors.grey[300],

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child:
                  imageUrlController
                          .text
                          .isEmpty

                      ? const Center(

                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        )

                      : ClipRRect(

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          child: Image.network(

                            imageUrlController
                                .text,

                            fit: BoxFit.cover,

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {

                              return const Center(
                                child: Text(
                                  "Invalid Image URL",
                                ),
                              );
                            },
                          ),
                        ),
            ),

            const SizedBox(height: 20),

            /// 📍 Name
            buildField(
              "Place Name",
              nameController,
            ),

            /// 📝 Description
            buildField(
              "Description",
              descriptionController,
            ),

            /// 🌐 Image URL
            buildField(
              "Image URL",
              imageUrlController,
            ),

            /// 🏷 Category
            DropdownButtonFormField<String>(

              value: selectedCategory,

              decoration: InputDecoration(

                labelText: "Category",

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Fort",
                  child: Text("Fort"),
                ),

                DropdownMenuItem(
                  value: "Castle",
                  child: Text("Castle"),
                ),

                DropdownMenuItem(
                  value: "Historical",
                  child: Text("Historical"),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  selectedCategory =
                      value!;
                });
              },
            ),

            const SizedBox(height: 15),

            /// 🕒 Opening Hours
            DropdownButtonFormField<String>(

              value:
                  selectedOpeningHours,

              decoration: InputDecoration(

                labelText:
                    "Opening Hours",

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "8 AM - 4 PM",
                  child:
                      Text("8 AM - 4 PM"),
                ),

                DropdownMenuItem(
                  value: "9 AM - 5 PM",
                  child:
                      Text("9 AM - 5 PM"),
                ),

                DropdownMenuItem(
                  value: "10 AM - 6 PM",
                  child:
                      Text("10 AM - 6 PM"),
                ),

                DropdownMenuItem(
                  value: "24 Hours",
                  child:
                      Text("24 Hours"),
                ),
              ],

              onChanged: (value) {

                setState(() {

                  selectedOpeningHours =
                      value!;
                });
              },
            ),

            const SizedBox(height: 15),

            /// 💰 Price
            DropdownButtonFormField<String>(

              value: selectedPrice,

              decoration: InputDecoration(

                labelText: "Price",

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Free",
                  child: Text("Free"),
                ),

                DropdownMenuItem(
                  value: "2 OMR",
                  child: Text("2 OMR"),
                ),

                DropdownMenuItem(
                  value: "5 OMR",
                  child: Text("5 OMR"),
                ),

                DropdownMenuItem(
                  value: "10 OMR",
                  child: Text("10 OMR"),
                ),
              ],

              onChanged: (value) {

                setState(() {
                  selectedPrice =
                      value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// 🗺 Change Location
            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                onPressed: () async {

                  final result =
                      await Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const MapPickerScreen(),
                    ),
                  );

                  if (result != null) {

                    setState(() {

                      latitude =
                          result['latitude'];

                      longitude =
                          result['longitude'];
                    });
                  }
                },

                icon:
                    const Icon(Icons.map),

                label: Text(

                  latitude == null
                      ? "Select Location"
                      : "Change Location",
                ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.orange,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            if (latitude != null)

              Padding(

                padding:
                    const EdgeInsets.only(
                  top: 10,
                ),

                child: Text(

                  "Lat: $latitude\nLng: $longitude",

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 25),

            /// 💾 Update Button
            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : updatePlace,

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.teal,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child: isLoading

                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )

                    : const Text(

                        "Update Place",

                        style: TextStyle(

                          fontSize: 18,

                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}