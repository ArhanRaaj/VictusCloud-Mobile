import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/billing_repository.dart';
import '../data/models/billing_models.dart';

final servicesProvider = FutureProvider.autoDispose<List<BillingService>>((ref) {
  return ref.read(billingRepositoryProvider).getServices();
});

final invoicesProvider = FutureProvider.autoDispose<List<Invoice>>((ref) {
  return ref.read(billingRepositoryProvider).getInvoices();
});

final ticketsProvider = FutureProvider.autoDispose<List<SupportTicket>>((ref) {
  return ref.read(billingRepositoryProvider).getTickets();
});

final ticketMessagesProvider = FutureProvider.family.autoDispose<List<TicketMessage>, String>((ref, ticketId) {
  return ref.read(billingRepositoryProvider).getTicketMessages(ticketId);
});

final storeCategoriesProvider = FutureProvider.autoDispose<List<StoreCategory>>((ref) {
  return ref.read(billingRepositoryProvider).getStoreCategories();
});

final storeProductsProvider = FutureProvider.family.autoDispose<List<StoreProduct>, String>((ref, categoryId) {
  return ref.read(billingRepositoryProvider).getStoreProducts(categoryId);
});
