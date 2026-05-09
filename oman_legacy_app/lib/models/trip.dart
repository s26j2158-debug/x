
class Trip {
  final String id;
  final String destination;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> itinerary;

  Trip({
    required this.id,
    required this.destination,
    required this.budget,
    required this.startDate,
    required this.endDate,
    this.itinerary =
        const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination':
          destination,
      'budget': budget,
      'start_date':
          startDate
              .toIso8601String(),
      'end_date':
          endDate
              .toIso8601String(),
      'itinerary':
          itinerary,
    };
  }

  factory Trip.fromMap(
      Map<String, dynamic> map) {
    return Trip(
      id: map['id']
          .toString(),
      destination:
          map['destination'],
      budget:
          (map['budget'] as num)
              .toDouble(),
      startDate:
          DateTime.parse(
        map['start_date'],
      ),
      endDate:
          DateTime.parse(
        map['end_date'],
      ),
      itinerary:
          List<String>.from(
        map['itinerary'] ??
            [],
      ),
    );
  }
}

