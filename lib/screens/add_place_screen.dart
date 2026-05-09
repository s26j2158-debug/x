import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() =>
      _AddPlaceScreenState();
}

class _AddPlaceScreenState
    extends State<AddPlaceScreen> {

  final supabase =
      Supabase.instance.client;

  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final openingHoursController =
      TextEditingController();

  bool isLoading = false;

  String selectedCategory = "Fort";


  String getImagePath() {

    if (selectedCategory == "Fort") {
      return 'images/fort.jpg';
    } else if (selectedCategory == "Castle") {
      return 'images/castle.jpg';
    } else {
      return 'images/heritage.jpg';
    }
  }

  /// ➕ Add place
  Future<void> addPlace() async {

    setState(() {
      isLoading = true;
    });

    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields',
          ),
        ),
      );

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {

      final user =
          supabase.auth.currentUser;

      await supabase
          .from('heritage_places')
          .insert({

        'name':
            nameController.text,

        'description':
            descriptionController.text,

        'image_url':
            getImagePath(),

        'category':
            selectedCategory,

        'opening_hours':
            openingHoursController.text,

        'user_id':
            user!.id,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Place added successfully',
          ),
        ),
      );

      Navigator.pop(context);

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

  /// 📝 TextField
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

        decoration: InputDecoration(
          labelText: label,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Add Heritage Place",
        ),

        backgroundColor:
            Colors.teal,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

        
            Container(

              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(

                borderRadius:
                    BorderRadius.circular(20),

                image: DecorationImage(

                  image: AssetImage(
                    getImagePath(),
                  ),

                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildField(
              "Place Name",
              nameController,
            ),

            buildField(
              "Description",
              descriptionController,
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
                      BorderRadius.circular(15),
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

            buildField(
              "Opening Hours",
              openingHoursController,
            ),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : addPlace,

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
                        "Add Place",

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