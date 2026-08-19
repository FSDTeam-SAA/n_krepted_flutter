import 'package:flutter/material.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository bookingRepository;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  BookingProvider({required this.bookingRepository});

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<bool> createReservation({
    required String dealId,
    required String userId,
    required DateTime date,
    int quantity = 1,
    required double price,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final booking = await bookingRepository.createBooking(
        dealId: dealId,
        userId: userId,
        scheduleDate: date,
        quantity: quantity,
        price: price,
      );
      _bookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await bookingRepository.getAllBookings();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
