class BillingService {
  final String id;
  final String name;
  final String status;
  final double price;
  final String billingCycle;
  final DateTime? nextDueDate;

  BillingService({
    required this.id,
    required this.name,
    required this.status,
    required this.price,
    required this.billingCycle,
    this.nextDueDate,
  });
}

class Invoice {
  final String id;
  final String status; // paid, unpaid, cancelled
  final double total;
  final DateTime dueDate;
  final String paymentUrl;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.status,
    required this.total,
    required this.dueDate,
    required this.paymentUrl,
    required this.items,
  });
}

class InvoiceItem {
  final String description;
  final double amount;
  InvoiceItem({required this.description, required this.amount});
}

class SupportTicket {
  final String id;
  final String subject;
  final String status; // open, answered, closed
  final String priority;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.priority,
    required this.updatedAt,
  });
}

class TicketMessage {
  final String id;
  final String content;
  final String authorName;
  final bool isStaff;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.content,
    required this.authorName,
    required this.isStaff,
    required this.createdAt,
  });
}

class StoreCategory {
  final String id;
  final String name;
  final String description;

  StoreCategory({
    required this.id,
    required this.name,
    required this.description,
  });
}

class StoreProduct {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double startingPrice;

  StoreProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.startingPrice,
  });
}
