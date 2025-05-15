import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'face_verification_service.dart';
import 'dart:io';
import '../../Widget/compress_image.dart';

class IdentityVerificationScreen extends StatefulWidget {
  @override
  _IdentityVerificationScreenState createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  XFile? idImage;
  XFile? selfieImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isSelfie) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isSelfie) {
          selfieImage = picked;
        } else {
          idImage = picked;
        }
      });
    }
  }

  void _submitVerification() async {
    if (idImage == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload both ID and selfie")),
      );
      return;
    }

    try {
      final File compressedID = await compressImage(File(idImage!.path));
      final File compressedSelfie = await compressImage(File(selfieImage!.path));

      final verifier = FaceVerificationService();
      final result = await verifier.compareFaces(compressedID, compressedSelfie);
      final confidence = result['confidence'] ?? 0;

      bool isMatch = confidence > 75;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(isMatch ? "✅ Identity Verified" : "❌ Verification Failed"),
          content: Text("Confidence: ${confidence.toStringAsFixed(2)}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text("Something went wrong:\n$e"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Identity Verification", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStepCard(
              title: "Step 1: Upload ID Card",
              description: "Take a clear photo of your government-issued ID card.",
              image: idImage,
              onPressed: () => _pickImage(false),
            ),
            SizedBox(height: 20),
            _buildStepCard(
              title: "Step 2: Take a Selfie",
              description: "Make sure your face is clearly visible.",
              image: selfieImage,
              onPressed: () => _pickImage(true),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitVerification,
                child: Text("Submit Verification"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  shape: StadiumBorder(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String description,
    XFile? image,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[200],
              backgroundImage: image != null ? FileImage(File(image.path)) : null,
              child: image == null ? Icon(Icons.image, size: 30, color: Colors.grey) : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  SizedBox(height: 10),
                  OutlinedButton(onPressed: onPressed, child: Text("Capture")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
