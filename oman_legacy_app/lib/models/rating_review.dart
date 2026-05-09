
class RatingReview {
  final String id;
  final int placeId;
  final double rating;
  final String review;
  final String userId;
  final DateTime createdAt;

  RatingReview({
    required this.id,
    required this.placeId,
    required this.rating,
    required this.review,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place_id': placeId,
      'rating': rating,
      'review': review,
      'user_id': userId,
      'created_at':
          createdAt
              .toIso8601String(),
    };
  }

  factory RatingReview.fromMap(
      Map<String, dynamic> map) {
    return RatingReview(
      id: map['id']
          .toString(),
      placeId:
          map['place_id'],
      rating:
          (map['rating'] as num)
              .toDouble(),
      review:
          map['review'],
      userId:
          map['user_id'],
      createdAt:
          DateTime.parse(
        map['created_at'],
      ),
    );
  }
}
