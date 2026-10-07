import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';
import 'package:victus_app/core/widgets/stat_chip.dart';
import '../../data/models/billing_summary.dart';

class SummaryStrip extends StatelessWidget {
  final BillingSummary summary;

  const SummaryStrip({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatChip(
            icon: Icons.dns_outlined,
            label: 'Active Servers',
            value: summary.activeServices.toString(),
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
          StatChip(
            icon: Icons.receipt_long_outlined,
            label: 'Unpaid Invoices',
            value: summary.unpaidInvoices.toString(),
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
          StatChip(
            icon: Icons.confirmation_number_outlined,
            label: 'Open Tickets',
            value: summary.openTickets.toString(),
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
          StatChip(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Balance',
            value: '${summary.accountBalance} ${summary.currency}',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
