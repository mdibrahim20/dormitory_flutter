import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'admission_form_screen.dart';

class ReservationScreen extends StatefulWidget {
  final DocumentSnapshot data;

  const ReservationScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final TextEditingController _couponController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<DateTime> _bookedDates = [];
  double _discount = 0;   // percentage
  double _finalPrice = 0; // final price after discount


  @override
  void initState() {
    super.initState();
    _fetchBookedDates();
  }

  Future<void> _fetchBookedDates() async {
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('dormitory_id', isEqualTo: widget.data.id)
        .get();

    List<DateTime> bookedDates = [];

    for (var doc in bookingsSnapshot.docs) {
      DateTime start = (doc['start_date'] as Timestamp).toDate();
      DateTime end = (doc['end_date'] as Timestamp).toDate();
      for (DateTime date = start;
      date.isBefore(end) || date.isAtSameMomentAs(end);
      date = date.add(const Duration(days: 1))) {
        bookedDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    setState(() {
      _bookedDates = bookedDates;
    });
  }

  Future<void> _validateCoupon() async {
    String code = _couponController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _discount = 0;
        _finalPrice = _totalPrice.toDouble();
      });
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('coupons')
        .where('code', isEqualTo: code)
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final coupon = query.docs.first;
      setState(() {
        _discount = coupon['discount']?.toDouble() ?? 0;
        _finalPrice = _totalPrice * (1 - _discount / 100);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon applied: $_discount% off!')),
      );
    } else {
      setState(() {
        _discount = 0;
        _finalPrice = _totalPrice.toDouble();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or inactive coupon')),
      );
    }
  }

  void _showDatePickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select your dates",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    _startDate = args.value.startDate;
                    _endDate = args.value.endDate;
                  });
                },
                monthViewSettings: DateRangePickerMonthViewSettings(
                  blackoutDates: _bookedDates,
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  blackoutDateTextStyle: TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onNextPressed() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in and check-out dates')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdmissionFormScreen(
          dormitoryData: widget.data,
          startDate: _startDate!,
          endDate: _endDate!,
          couponCode: _couponController.text.trim(),
          discount: _discount,
          finalPrice: _finalPrice > 0 ? _finalPrice : _totalPrice.toDouble(),
        ),
      ),
    );
  }



  int get _numberOfNights {
    if (_startDate != null && _endDate != null) {
      return _endDate!.difference(_startDate!).inDays;
    }
    return 0;
  }

  int get _totalPrice {
    int pricePerNight = widget.data['price'] ?? 0;
    return pricePerNight * _numberOfNights;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Review & Continue", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Image with overlay text
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      data['image_url'],
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        data['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ⭐ Rating
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text("${data['rating']} • Guest Favorite", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 24),

              // ⭐ Coupon input
              Text("Have a coupon?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              const SizedBox(height: 8),
              TextField(
                controller: _couponController,
                decoration: InputDecoration(
                  hintText: "Enter coupon code",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _validateCoupon,
                child: const Text("Apply Coupon"),
              ),

              const SizedBox(height: 24),

              // ⭐ Date Picker button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showDatePickerModal,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Choose Dates", style: TextStyle(fontSize: 16)),
              ),

              if (_startDate != null && _endDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.date_range, color: Colors.black),
                      Text(
                        "${_startDate!.toLocal().toString().split(' ')[0]} → ${_endDate!.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ⭐ Price details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Booking Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 16),
                    _priceRow("Price per night", "\৳${data['price']}"),
                    _priceRow("Nights", _numberOfNights.toString()),
                    const Divider(height: 24, thickness: 1),
                    _priceRow(
                      "Total",
                      _discount > 0
                          ? "\৳${_finalPrice.toStringAsFixed(2)} (after $_discount% off)"
                          : "\৳$_totalPrice",
                      isBold: true,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ⭐ Next button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _onNextPressed,
                child: const Text("Next: Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper for price rows
  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
