import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/billing_provider.dart';
import '../data/models/billing_models.dart';
import '../widgets/service_detail_modal.dart';
import '../widgets/invoice_detail_modal.dart';
import 'ticket_detail_screen.dart';
import 'order_service_screen.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Billing & Support', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF8A8A8A),
          dividerColor: const Color(0xFF262626),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Invoices'),
            Tab(text: 'Tickets'),
            Tab(text: 'Store'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ServicesTab(),
          _InvoicesTab(),
          _TicketsTab(),
          _StoreTab(),
        ],
      ),
    );
  }
}

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Center(child: Text('No services found.', style: TextStyle(color: Color(0xFF8A8A8A))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final isActive = service.status.toLowerCase() == 'active';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF262626)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text('\$${service.price.toStringAsFixed(2)} / ${service.billingCycle}', style: const TextStyle(color: Color(0xFF8A8A8A))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 10, color: isActive ? Colors.white : const Color(0xFF8A8A8A)),
                    const SizedBox(width: 8),
                    Text(service.status.toUpperCase(), style: TextStyle(color: isActive ? Colors.white : const Color(0xFF8A8A8A), fontSize: 12)),
                  ],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => ServiceDetailModal(service: service),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(child: Text('Error: \$e', style: const TextStyle(color: Colors.white))),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return invoicesAsync.when(
      data: (invoices) {
        if (invoices.isEmpty) {
          return const Center(child: Text('No invoices found.', style: TextStyle(color: Color(0xFF8A8A8A))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            final isPaid = invoice.status.toLowerCase() == 'paid';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF262626)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  isPaid ? Icons.check_circle : Icons.circle_outlined,
                  color: isPaid ? Colors.white : const Color(0xFF8A8A8A),
                ),
                title: Text(invoice.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text('Due: \${invoice.dueDate.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Color(0xFF8A8A8A))),
                trailing: Text('\$${invoice.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => InvoiceDetailModal(invoice: invoice),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(child: Text('Error: \$e', style: const TextStyle(color: Colors.white))),
    );
  }
}

class _TicketsTab extends ConsumerWidget {
  const _TicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return ticketsAsync.when(
      data: (tickets) {
        return Stack(
          children: [
            if (tickets.isEmpty)
              const Center(child: Text('No tickets found.', style: TextStyle(color: Color(0xFF8A8A8A))))
            else
              ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      border: Border.all(color: const Color(0xFF262626)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(ticket.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      subtitle: Text('Status: \${ticket.status}', style: const TextStyle(color: Color(0xFF8A8A8A))),
                      trailing: Text(ticket.priority, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)));
                      },
                    ),
                  );
                },
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: () {
                  // Open create ticket modal
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(child: Text('Error: \$e', style: const TextStyle(color: Colors.white))),
    );
  }
}

class _StoreTab extends ConsumerWidget {
  const _StoreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(storeCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available.', style: TextStyle(color: Color(0xFF8A8A8A))));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ExpansionTile(
              title: Text(category.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(category.description, style: const TextStyle(color: Color(0xFF8A8A8A))),
              iconColor: Colors.white,
              collapsedIconColor: const Color(0xFF8A8A8A),
              children: [
                _StoreProductsList(categoryId: category.id),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(child: Text('Error: \$e', style: const TextStyle(color: Colors.white))),
    );
  }
}

class _StoreProductsList extends ConsumerWidget {
  final String categoryId;
  const _StoreProductsList({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(storeProductsProvider(categoryId));
    return productsAsync.when(
      data: (products) {
        return Column(
          children: products.map((product) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFF262626)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(product.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(product.description, style: const TextStyle(color: Color(0xFF8A8A8A))),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderServiceScreen(product: product)));
                  },
                  child: Text('From \$${product.startingPrice}'),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: \$e', style: const TextStyle(color: Colors.white))),
    );
  }
}
