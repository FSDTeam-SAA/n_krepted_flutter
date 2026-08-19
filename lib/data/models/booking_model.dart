class BookingModel {
  final String id;
  final String bookingId;
  final String userId;
  final String dealId;
  final String? restaurantName;
  final double price;
  final int quantity;
  final DateTime scheduleDate;
  final String paymentStatus;
  final bool isBooked;

  BookingModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.dealId,
    this.restaurantName,
    required this.price,
    this.quantity = 1,
    required this.scheduleDate,
    this.paymentStatus = 'complete',
    this.isBooked = true,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String rName = 'Restaurant JAN';
    if (json['dealsId'] is Map<String, dynamic>) {
      rName = json['dealsId']['title'] ?? 'Restaurant JAN';
    }

    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? 'BK-1001',
      userId: json['userId'] is Map ? json['userId']['_id'] : (json['userId'] ?? ''),
      dealId: json['dealsId'] is Map ? json['dealsId']['_id'] : (json['dealsId'] ?? ''),
      restaurantName: rName,
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 15.45,
      quantity: json['quantity'] ?? 1,
      scheduleDate: json['scheduleDate'] != null ? DateTime.parse(json['scheduleDate']) : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? 'complete',
      isBooked: json['isBooked'] ?? true,
    );
  }
}
