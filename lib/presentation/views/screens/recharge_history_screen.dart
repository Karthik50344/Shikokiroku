import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/reminder.dart';
import '../../bloc/recharge/recharge_bloc.dart';
import '../../router/app_router.dart';

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<RechargeBloc, RechargeState>(
        builder: (context, state) {
          if (state is RechargeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RechargeLoaded) {
            final allRecharges = state.recharges;

            if (allRecharges.isEmpty) {
              return _buildEmptyState(context);
            }

            // Group recharges by status
            final activeRecharges =
            allRecharges.where((r) => !r.isExpired).toList();
            final expiredRecharges =
            allRecharges.where((r) => r.isExpired).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeRecharges.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Active Recharges',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  ...activeRecharges.map((recharge) =>
                      _buildRechargeCard(context, recharge, false)),
                  const SizedBox(height: 24),
                ],
                if (expiredRecharges.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Expired Recharges',
                    Icons.history,
                    Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  ...expiredRecharges.map((recharge) =>
                      _buildRechargeCard(context, recharge, true)),
                ],
              ],
            );
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRechargeCard(
      BuildContext context,
      MobileRecharge recharge,
      bool isExpired,
      ) {
    final statusColor = isExpired
        ? Colors.grey
        : (recharge.isExpiringSoon ? Colors.orange : Colors.green);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRechargeDetails(context, recharge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recharge.mobileNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recharge.operator} • ₹${recharge.amount}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y').format(recharge.rechargeDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      isExpired ? 'Expired' : 'Active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recharge.validityDays} days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No recharge history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recharge records will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(AppRouter.addRecharge),
            icon: const Icon(Icons.add),
            label: const Text('Add First Recharge'),
          ),
        ],
      ),
    );
  }

  void _showRechargeDetails(BuildContext context, MobileRecharge recharge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recharge Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(AppRouter.editRecharge, extra: recharge);
                  },
                  tooltip: 'Edit',
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Mobile Number', recharge.mobileNumber),
            _buildDetailRow('Operator', recharge.operator),
            _buildDetailRow('Amount', '₹${recharge.amount}'),
            _buildDetailRow(
              'Recharge Date',
              DateFormat('MMM d, y').format(recharge.rechargeDate),
            ),
            _buildDetailRow('Validity', '${recharge.validityDays} days'),
            _buildDetailRow(
              'Expiry Date',
              DateFormat('MMM d, y').format(recharge.expiryDate),
            ),
            _buildDetailRow(
              'Days Remaining',
              recharge.isExpired
                  ? 'Expired'
                  : '${recharge.daysRemaining} days',
            ),
            _buildDetailRow(
              'Reminder',
              recharge.reminderEnabled
                  ? '${recharge.reminderDaysBefore} days before'
                  : 'Disabled',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: recharge.isExpired
                    ? Colors.red.withOpacity(0.1)
                    : (recharge.isExpiringSoon
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: recharge.isExpired
                      ? Colors.red.withOpacity(0.3)
                      : (recharge.isExpiringSoon
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    recharge.isExpired
                        ? Icons.error
                        : (recharge.isExpiringSoon
                        ? Icons.warning
                        : Icons.check_circle),
                    color: recharge.isExpired
                        ? Colors.red
                        : (recharge.isExpiringSoon
                        ? Colors.orange
                        : Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recharge.isExpired
                          ? 'This recharge has expired'
                          : (recharge.isExpiringSoon
                          ? 'Expiring soon! Recharge now.'
                          : 'Recharge is active'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: recharge.isExpired
                            ? Colors.red
                            : (recharge.isExpiringSoon
                            ? Colors.orange
                            : Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}