import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final ApiClient apiClient;

  BookingRepository({required this.apiClient});

  Future<BookingModel> createBooking({
    required String dealId,
    required String userId,
    required DateTime scheduleDate,
    int quantity = 1,
    required double price,
  }) async {
    final response = await apiClient.post(
      ApiConstants.bookings,
      data: {
        'dealsId': dealId,
        'userId': userId,
        'scheduleDate': scheduleDate.toIso8601String(),
        'quantity': quantity,
        'price': price,
        'notifyMe': false,
        'isBooked': true,
      },
    );

    if (response.data != null && (response.data['success'] == true || response.data['booking'] != null)) {
      final b = response.data['booking'] ?? response.data['data'];
      return BookingModel.fromJson(b);
    }
    throw Exception(response.data?['message'] ?? 'Fehler beim Erstellen der Reservierung');
  }

  Future<List<BookingModel>> getAllBookings() async {
    final response = await apiClient.get(ApiConstants.bookings);
    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    }
    return [];
  }
}
