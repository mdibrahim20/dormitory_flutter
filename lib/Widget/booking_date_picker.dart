import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class BookingDateRangePicker extends StatefulWidget {
  final String hotelId;

  const BookingDateRangePicker({super.key, required this.hotelId});

  @override
  State<BookingDateRangePicker> createState() => _BookingDateRangePickerState();
}

class _BookingDateRangePickerState extends State<BookingDateRangePicker> {
  DateTimeRange? selectedDateRange;
  List<DateTime> blockedDates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);

    String userId = "test_user_123";
    // FirebaseAuth.instance.currentUser!.uid for production

    List<DateTime> otherUsersDates = [];
    DateTimeRange? userRange;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('dormitory_id', isEqualTo: widget.hotelId)
          .get();

      for (var doc in snapshot.docs) {
        DateTime start = (doc['start_date'] as Timestamp).toDate();
        DateTime end = (doc['end_date'] as Timestamp).toDate();
        String bookingUser = doc['user_id'];

        if (bookingUser == userId) {
          userRange = DateTimeRange(start: start, end: end);
        } else {
          for (DateTime date = start;
          date.isBefore(end) || date.isAtSameMomentAs(end);
          date = date.add(const Duration(days: 1))) {
            otherUsersDates.add(date);
          }
        }
      }

      setState(() {
        blockedDates = otherUsersDates;
        selectedDateRange = userRange;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load bookings.")),
      );
    }
  }

  bool isBlocked(DateTime date) {
    return blockedDates.any((blocked) =>
    blocked.year == date.year &&
        blocked.month == date.month &&
        blocked.day == date.day);
  }

  Future<void> saveBooking() async {
    if (selectedDateRange == null) return;

    String userId = "test_user_123";

    try {
      final query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('dormitory_id', isEqualTo: widget.hotelId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'start_date': Timestamp.fromDate(selectedDateRange!.start),
          'end_date': Timestamp.fromDate(selectedDateRange!.end),
        });
        showMessage("Booking updated!");
      } else {
        await FirebaseFirestore.instance.collection('bookings').add({
          'dormitory_id': widget.hotelId,
          'user_id': userId,
          'start_date': Timestamp.fromDate(selectedDateRange!.start),
          'end_date': Timestamp.fromDate(selectedDateRange!.end),
        });
        showMessage("Booking added!");
      }

      fetchBookings();
    } catch (e) {
      debugPrint("Error saving booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save booking.")),
      );
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "$text\n${_formatDate(selectedDateRange!.start)} → ${_formatDate(selectedDateRange!.end)}"),
      ),
    );
  }

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) async {
    if (args.value is PickerDateRange) {
      DateTime start = args.value.startDate!;
      DateTime end = args.value.endDate ?? start;

      bool conflict = false;
      for (DateTime date = start;
      date.isBefore(end) || date.isAtSameMomentAs(end);
      date = date.add(const Duration(days: 1))) {
        if (isBlocked(date)) {
          conflict = true;
          break;
        }
      }

      if (conflict) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text("Selected range includes already booked dates.")),
        );
        return;
      }

      setState(() {
        selectedDateRange = DateTimeRange(start: start, end: end);
      });

      await saveBooking();
      Navigator.of(context).pop(); // Close bottom sheet after booking
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: selectedDateRange != null
                      ? PickerDateRange(selectedDateRange!.start,
                      selectedDateRange!.end)
                      : null,
                  onSelectionChanged: onSelectionChanged,
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    blackoutDateTextStyle: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough),
                  ),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                      blackoutDates: blockedDates),
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.date_range),
          label: Text(selectedDateRange != null
              ? "Change Booking Dates"
              : "Select Booking Dates"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (selectedDateRange != null)
          Text(
            'Your Booking: ${_formatDate(selectedDateRange!.start)} → ${_formatDate(selectedDateRange!.end)}',
            style:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
