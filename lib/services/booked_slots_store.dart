/// In-memory store of confirmed appointment slots so the same slot
/// is not shown as available to other users (or same user) after booking.
/// With a real backend, the API would return only available slots and
/// persist bookings; this store mirrors that for the session.
class BookedSlotsStore {
  BookedSlotsStore._();

  static final Set<String> _booked = {};

  static String _key(String doctorId, String date, String timeSlot) {
    return '$doctorId|$date|$timeSlot';
  }

  static void addBookedSlot(String doctorId, String date, String timeSlot) {
    _booked.add(_key(doctorId, date, timeSlot));
  }

  /// Removes a booked slot so it appears available again (e.g. after cancellation).
  static void removeBookedSlot(String doctorId, String date, String timeSlot) {
    _booked.remove(_key(doctorId, date, timeSlot));
  }

  static bool isBooked(String doctorId, String date, String timeSlot) {
    return _booked.contains(_key(doctorId, date, timeSlot));
  }
}
