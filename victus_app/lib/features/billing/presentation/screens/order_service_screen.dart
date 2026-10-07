import 'package:flutter/material.dart';
import '../../data/models/billing_models.dart';

class OrderServiceScreen extends StatefulWidget {
  final StoreProduct product;

  const OrderServiceScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<OrderServiceScreen> createState() => _OrderServiceScreenState();
}

class _OrderServiceScreenState extends State<OrderServiceScreen> {
  String _selectedBillingCycle = 'Monthly';
  final List<String> _billingCycles = ['Monthly', 'Quarterly', 'Annually'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Configure Order', style: TextStyle(color: Colors.white, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF262626), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.product.description, style: const TextStyle(color: Color(0xFF8A8A8A))),
            const SizedBox(height: 24),
            const Text('Choose Billing Cycle', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._billingCycles.map((cycle) {
              final isSelected = _selectedBillingCycle == cycle;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBillingCycle = cycle;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF111111),
                    border: Border.all(color: isSelected ? Colors.white : const Color(0xFF262626)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cycle, style: const TextStyle(color: Colors.white)),
                      Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? Colors.white : const Color(0xFF8A8A8A)),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 32),
            // Configuration options (e.g. RAM, CPU) could be added here
            const Text('Configuration', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF262626)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No additional configuration required for this plan.', style: TextStyle(color: Color(0xFF8A8A8A))),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          border: Border(top: BorderSide(color: Color(0xFF262626))),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total due today', style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                Text('\$${widget.product.startingPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Checkout flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
