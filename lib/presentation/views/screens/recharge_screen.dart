import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shiki/presentation/views/widgets/reminder_action.dart';
import '../../../domain/models/reminder.dart';
import '../../bloc/recharge/recharge_bloc.dart';
import '../../router/app_router.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RechargeBloc, RechargeState>(
        listener: (context, state) {
          if (state is RechargeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RechargeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Mobile Recharge', style: TextStyle(color: Colors.purple),),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.purple,),
                onPressed: () => context.go(AppRouter.home),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.purple,),
                  onPressed: () => context.push(AppRouter.rechargeHistory),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(context),
                    const SizedBox(height: 24),
                    const Text(
                      'Active Recharges',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildRechargesList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addRecharge),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text('Add Recharge', style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return BlocBuilder<RechargeBloc, RechargeState>(
      builder: (context, state) {
        int expiringSoon = 0;
        int expired = 0;
        int active = 0;

        if (state is RechargeLoaded) {
          expiringSoon = state.expiringSoonRecharges.length;
          expired = state.expiredRecharges.length;
          active = state.activeRecharges.length;
        }

        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Active',
                active.toString(),
                Icons.phone_android,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Expiring Soon',
                expiringSoon.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Expired',
                expired.toString(),
                Icons.error,
                Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRechargesList(BuildContext context) {
    return BlocBuilder<RechargeBloc, RechargeState>(
      builder: (context, state) {
        if (state is RechargeLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RechargeLoaded) {
          final recharges = state.activeRecharges;

          if (recharges.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active recharges',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildRechargeCard(context, recharges[index]);
                },
                childCount: recharges.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Unable to load recharges')),
        );
      },
    );
  }

  Widget _buildRechargeCard(BuildContext context, MobileRecharge recharge) {
    final daysRemaining = recharge.daysRemaining;
    final isExpiringSoon = recharge.isExpiringSoon;
    final progressValue =
        (recharge.validityDays - daysRemaining) / recharge.validityDays;

    Color statusColor = Colors.green;
    if (isExpiringSoon) {
      statusColor = Colors.orange;
    }
    if (recharge.isExpired) {
      statusColor = Colors.red;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.push(AppRouter.editRecharge, extra: recharge),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => RechargeActions.showActionSheet(context, recharge),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showRechargeDetails(context, recharge),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            recharge.operator,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${recharge.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$daysRemaining days',
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Validity Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${(progressValue * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        backgroundColor: statusColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.calendar_today,
                      'Recharged: ${DateFormat('MMM d, y').format(recharge.rechargeDate)}',
                    ),
                    _buildInfoChip(
                      context,
                      Icons.event,
                      'Expires: ${DateFormat('MMM d, y').format(recharge.expiryDate)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
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
            const Text(
              'Recharge Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            _buildDetailRow('Days Remaining', '${recharge.daysRemaining}'),
            _buildDetailRow(
              'Reminder',
              recharge.reminderEnabled
                  ? '${recharge.reminderDaysBefore} days before'
                  : 'Disabled',
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