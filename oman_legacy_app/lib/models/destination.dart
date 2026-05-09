class Destination {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final double latitude;
  final double longitude;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromMap(
      Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      description:
          map['description'],
      imageUrl:
          map['image_url'],
      category:
          map['category'],
      price:
          (map['price'] as num)
              .toDouble(),
      latitude:
          (map['latitude']
                  as num)
              .toDouble(),
      longitude:
          (map['longitude']
                  as num)
              .toDouble(),
    );
  }
}
