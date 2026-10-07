import 'package:flutter/material.dart';
import '../../data/models/billing_models.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceDetailModal extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailModal({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status.toLowerCase() == 'paid';
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Color(0xFF262626))),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice ${invoice.id}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.white : Colors.transparent,
                    border: Border.all(color: isPaid ? Colors.white : const Color(0xFF8A8A8A)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    invoice.status.toUpperCase(),
                    style: TextStyle(color: isPaid ? Colors.black : const Color(0xFF8A8A8A), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Items', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.description, style: const TextStyle(color: Colors.white)),
                        Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Color(0xFF262626), height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${invoice.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            if (!isPaid)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(invoice.paymentUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
