class BillingSummary {
  final int activeServices;
  final int unpaidInvoices;
  final int openTickets;
  final double accountBalance;
  final String currency;

  const BillingSummary({
    required this.activeServices,
    required this.unpaidInvoices,
    required this.openTickets,
    required this.accountBalance,
    required this.currency,
  });

  factory BillingSummary.fromJson(Map<String, dynamic> json) {
    return BillingSummary(
      activeServices: json['active_services'] as int? ?? 0,
      unpaidInvoices: json['unpaid_invoices'] as int? ?? 0,
      openTickets: json['open_tickets'] as int? ?? 0,
      accountBalance: (json['account_balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_services': activeServices,
      'unpaid_invoices': unpaidInvoices,
      'open_tickets': openTickets,
      'account_balance': accountBalance,
      'currency': currency,
    };
  }
}
