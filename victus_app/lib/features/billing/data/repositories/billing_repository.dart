import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/billing_models.dart';
// Note: PaymenterClient should be integrated here. Using mock data for runnable UI demonstration.
// import '../../../core/network/paymenter_client.dart';

class BillingRepository {
  Future<List<BillingService>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      BillingService(
        id: 's1',
        name: 'Performance VPS - 8GB RAM',
        status: 'active',
        price: 15.0,
        billingCycle: 'Monthly',
        nextDueDate: DateTime.now().add(const Duration(days: 12)),
      ),
      BillingService(
        id: 's2',
        name: 'Basic Shared Hosting',
        status: 'suspended',
        price: 2.50,
        billingCycle: 'Monthly',
        nextDueDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<List<Invoice>> getInvoices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Invoice(
        id: 'INV-1045',
        status: 'unpaid',
        total: 17.50,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        paymentUrl: 'https://paymenter.org/pay/inv-1045',
        items: [
          InvoiceItem(description: 'Performance VPS - 8GB RAM (Nov)', amount: 15.0),
          InvoiceItem(description: 'Basic Shared Hosting (Nov)', amount: 2.50),
        ],
      ),
      Invoice(
        id: 'INV-1002',
        status: 'paid',
        total: 15.0,
        dueDate: DateTime.now().subtract(const Duration(days: 25)),
        paymentUrl: 'https://paymenter.org/pay/inv-1002',
        items: [
          InvoiceItem(description: 'Performance VPS - 8GB RAM (Oct)', amount: 15.0),
        ],
      ),
    ];
  }

  Future<List<SupportTicket>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      SupportTicket(
        id: 'TKT-991',
        subject: 'Server Upgrade Inquiry',
        status: 'open',
        priority: 'low',
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      SupportTicket(
        id: 'TKT-985',
        subject: 'DDoS Protection False Positive',
        status: 'closed',
        priority: 'high',
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<List<TicketMessage>> getTicketMessages(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TicketMessage(
        id: 'msg1',
        content: 'Hello, I was wondering how I can upgrade my RAM without losing data.',
        authorName: 'User',
        isStaff: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      TicketMessage(
        id: 'msg2',
        content: 'Hi there, you can upgrade directly from the client area, and the hypervisor will simply restart your instance with the new allocation. No data loss will occur.',
        authorName: 'Support Staff',
        isStaff: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  Future<void> replyTicket(String ticketId, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful reply
  }

  Future<void> createTicket(String subject, String message, String priority) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful creation
  }

  Future<List<StoreCategory>> getStoreCategories() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      StoreCategory(id: 'c1', name: 'VPS Hosting', description: 'High-performance KVM instances'),
      StoreCategory(id: 'c2', name: 'Dedicated Servers', description: 'Bare metal for maximum power'),
    ];
  }

  Future<List<StoreProduct>> getStoreProducts(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (categoryId == 'c1') {
      return [
        StoreProduct(id: 'p1', categoryId: 'c1', name: 'KVM 2GB', description: '2GB RAM, 1 vCPU, 20GB NVMe', startingPrice: 4.0),
        StoreProduct(id: 'p2', categoryId: 'c1', name: 'KVM 8GB', description: '8GB RAM, 4 vCPU, 80GB NVMe', startingPrice: 15.0),
      ];
    }
    return [];
  }
}

final billingRepositoryProvider = Provider((ref) => BillingRepository());
