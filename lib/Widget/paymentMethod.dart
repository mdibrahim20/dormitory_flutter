// lib/widgets/payment_method_modal.dart
import 'package:flutter/material.dart';

class PaymentMethodModal extends StatefulWidget {
  final Function(String method, Map<String, String> details) onPaymentConfirmed;

  const PaymentMethodModal({super.key, required this.onPaymentConfirmed});

  @override
  State<PaymentMethodModal> createState() => _PaymentMethodModalState();
}

class _PaymentMethodModalState extends State<PaymentMethodModal> {
  int step = 0; // 0 = select method, 1 = card, 2 = online

  // Controllers
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  final cardHolderNameController = TextEditingController();
  final transactionIdController = TextEditingController();
  final accountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: step == 0 ? _buildMethodSelection() : step == 1 ? _buildCardForm() : _buildOnlineForm(),
      ),
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.money),
          title: const Text("Cash on Arrival"),
          onTap: () => widget.onPaymentConfirmed("Cash on Arrival", {}),
        ),
        ListTile(
          leading: const Icon(Icons.credit_card),
          title: const Text("Credit/Debit Card"),
          onTap: () => setState(() => step = 1),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text("Online Transfer"),
          onTap: () => setState(() => step = 2),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextField(controller: cardNumberController, decoration: const InputDecoration(labelText: 'Card Number')),
        TextField(controller: expiryDateController, decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)')),
        TextField(controller: cvvController, decoration: const InputDecoration(labelText: 'CVV'), obscureText: true),
        TextField(controller: cardHolderNameController, decoration: const InputDecoration(labelText: 'Cardholder Name')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            widget.onPaymentConfirmed("Credit/Debit Card", {
              'cardNumber': cardNumberController.text,
              'expiryDate': expiryDateController.text,
              'cvv': cvvController.text,
              'cardHolderName': cardHolderNameController.text,
            });
          },
          child: const Text("Confirm Card Payment"),
        ),
      ],
    );
  }

  Widget _buildOnlineForm() {
    return Column(
      children: [
        TextField(controller: transactionIdController, decoration: const InputDecoration(labelText: 'Transaction ID')),
        TextField(controller: accountNameController, decoration: const InputDecoration(labelText: 'Account Name')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            widget.onPaymentConfirmed("Online Transfer", {
              'transactionId': transactionIdController.text,
              'accountName': accountNameController.text,
            });
          },
          child: const Text("Confirm Online Payment"),
        ),
      ],
    );
  }
}