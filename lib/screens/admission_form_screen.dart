import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_screen.dart';
class AdmissionFormScreen extends StatefulWidget {
  final DocumentSnapshot dormitoryData;
  final DateTime startDate;
  final DateTime endDate;
  final String couponCode;
  final double discount;
  final double finalPrice;

  const AdmissionFormScreen({
    Key? key,
    required this.dormitoryData,
    required this.startDate,
    required this.endDate,
    required this.couponCode,
    required this.discount,
    required this.finalPrice,
  }) : super(key: key);

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}


class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isStudent = true;
  bool _acceptedTerms = false;
  bool _formSubmitted = false;

  // Common fields
  final _studentName = TextEditingController();
  final _mobileNo = TextEditingController();
  final _permanentAddress = TextEditingController();
  final _presentAddress = TextEditingController();
  String? _gender;

  // Student-only fields
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _institutionName = TextEditingController();
  final _class = TextEditingController();
  final _rollNo = TextEditingController();
  final _bloodGroup = TextEditingController();
  final _religion = TextEditingController();

  // Emergency Contact / Guardian fields
  final _contactName = TextEditingController();
  final _contactRelation = TextEditingController();
  final _contactMobile = TextEditingController();
  final _contactAddress = TextEditingController();

  // Non-student extra
  final _passportNID = TextEditingController();

  void _showTermsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Text(
            '''
1. The student must maintain Younic Home’s rules and regulations properly.
2. The student must be polite and well-behaved with everyone.
3. No outsider or guest can stay in the dormitory without permission.
4. The student must return to the hostel within the fixed time every day.
5. Any illegal activity inside the hostel will lead to immediate cancellation of admission.
6. Monthly rent must be paid within the first 10 days of each month.
7. If rent is unpaid for 2 consecutive months, admission will be canceled.
8. Students must take care of hostel properties. Damages must be compensated.
9. Students must inform the management before leaving the hostel.
10. The hostel authority holds the right to change any rules if necessary.
11. The authority is not responsible for any loss of student valuables.
12. Students must ensure cleanliness of their room and surroundings.
13. Loud noises, playing loud music, or creating any nuisance is strictly prohibited.
14. Use of drugs, alcohol, smoking, or any type of banned substances is strictly prohibited.
15. Disrespecting hostel staff will not be tolerated.
16. Violation of any rule will lead to strict action or cancellation of hostel seat.

Declaration:
I, the undersigned, have read and understood all the rules of Younic Home and agree to abide by them fully.
            ''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        // 👉 Save booking and get document reference
        final bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
          'user_id': FirebaseAuth.instance.currentUser!.uid,
          'dormitory_id': widget.dormitoryData.id,
          'user_name': _studentName.text,
          'contact_info': _mobileNo.text,
          'start_date': Timestamp.fromDate(widget.startDate),
          'end_date': Timestamp.fromDate(widget.endDate),
          'payment_status': 'unpaid',
          'coupon_code': widget.couponCode,
          'discount': widget.discount,
          'final_price': widget.finalPrice,
          'is_student': _isStudent,
          'permanent_address': _permanentAddress.text,
          'present_address': _presentAddress.text,
          'gender': _gender ?? '',
          // 👇 Student info
          'father_name': _isStudent ? _fatherName.text : '',
          'mother_name': _isStudent ? _motherName.text : '',
          'institution_name': _isStudent ? _institutionName.text : '',
          'class': _isStudent ? _class.text : '',
          'roll_no': _isStudent ? _rollNo.text : '',
          'blood_group': _isStudent ? _bloodGroup.text : '',
          'religion': _isStudent ? _religion.text : '',
          // 👇 Guardian / Emergency
          'guardian_name': _contactName.text,
          'guardian_relation': _contactRelation.text,
          'guardian_mobile': _contactMobile.text,
          'guardian_address': _contactAddress.text,
          // 👇 Non-student
          'passport_nid': !_isStudent ? _passportNID.text : '',
          'created_at': FieldValue.serverTimestamp(),
        });

        // 👉 Immediately navigate to PaymentScreen with bookingId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              bookingId: bookingRef.id,
              finalPrice: widget.finalPrice,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Admission Form", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔘 Student switch
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Booking Summary", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Dormitory: ${widget.dormitoryData['name']}"),
                    Text("Check-in: ${widget.startDate.toLocal().toString().split(' ')[0]}"),
                    Text("Check-out: ${widget.endDate.toLocal().toString().split(' ')[0]}"),
                    Text("Coupon: ${widget.couponCode.isNotEmpty ? widget.couponCode : 'None'}"),
                    Text("Discount: ${widget.discount}%"),
                    Text("Price after Discount: \৳${widget.finalPrice.toStringAsFixed(2)}"),
                  ],
                ),
              ),
              // 🔘 Student switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Non-Student", style: TextStyle(fontSize: 14)),
                    Switch(
                      value: _isStudent,
                      onChanged: (val) => setState(() => _isStudent = val),
                    ),
                    const Text("Student", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),



              const SizedBox(height: 20),

              // ⭐ Common fields
              _sectionTitle("Personal Information"),
              _customField(_studentName, "Name", required: true),
              _customField(_mobileNo, "Mobile No", required: true),
              _customField(_permanentAddress, "Permanent Address", required: true),
              _customField(_presentAddress, "Present Address", required: true),

              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _inputDecoration("Gender"),
                items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => _gender = value),
              ),

              // ⭐ Student-only fields
              if (_isStudent) ...[
                const SizedBox(height: 20),
                _sectionTitle("Student Details"),
                _customField(_fatherName, "Father's Name", required: _isStudent),
                _customField(_motherName, "Mother's Name", required: _isStudent),
                _customField(_institutionName, "Institution Name", required: _isStudent),
                _customField(_class, "Class", required: _isStudent),
                _customField(_rollNo, "Roll No", required: _isStudent),
                _customField(_bloodGroup, "Blood Group", required: _isStudent),
                _customField(_religion, "Religion", required: _isStudent),

              ],

              const SizedBox(height: 20),

              // ⭐ Contact Details
              _sectionTitle(_isStudent ? "Guardian Details" : "Emergency Contact Details"),
              _customField(_contactName, "Guardian Name", required: true),
              _customField(_contactRelation, "Guardian's Relation", required: true),
              _customField(_contactMobile, "Guardian's Mobile", required: true),
              _customField(_contactAddress, "Guardian's Address", required: true),


              // ⭐ Passport/NID for non-student
              if (!_isStudent) _customField(_passportNID, "Passport / NID Number", required: true),


              const SizedBox(height: 25),

              // ✔ Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (val) => setState(() => _acceptedTerms = val!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTermsModal,
                      child: const Text(
                        "I accept Terms and Conditions",
                        style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _submitForm,
                child: const Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

              ),
              // if (_formSubmitted) ...[
              //   const SizedBox(height: 16),
              //   ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.green,
              //       minimumSize: const Size(double.infinity, 55),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              //     ),
              //     onPressed: () {
              //       // 👉 Push next page (e.g. Contract Agreement Page)
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => PaymentScreen(bookingId: '',), // 🔧 your next page widget
              //         ),
              //       );
              //     },
              //     child: const Text("Next: Review Contract", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              //   ),
              // ]

            ],
          ),
        ),
      ),
    );
  }

// 🛠️ Helper widgets

  Widget _customField(TextEditingController controller, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        validator: required
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        }
            : null,
      ),
    );
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

}
