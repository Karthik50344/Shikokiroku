import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/reminder.dart';
import '../../bloc/reminder/reminder_bloc.dart';
import '../../bloc/recharge/recharge_bloc.dart';
import '../../router/app_router.dart';

class ReminderActions {
  // Show action sheet with edit and delete options
  static void showActionSheet(BuildContext context, Reminder reminder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              title: const Text('Edit Reminder'),
              subtitle: const Text('Modify reminder details'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.editReminder, extra: reminder);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: reminder.isCompleted
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  reminder.isCompleted ? Icons.restart_alt : Icons.check_circle,
                  color: reminder.isCompleted ? Colors.orange : Colors.green,
                ),
              ),
              title: Text(
                  reminder.isCompleted ? 'Mark as Active' : 'Mark as Complete'),
              subtitle: Text(reminder.isCompleted
                  ? 'Reactivate this reminder'
                  : 'Mark this reminder as done'),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<ReminderBloc>()
                    .add(ToggleReminderComplete(reminder.id));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text('Delete Reminder'),
              subtitle: const Text('Remove this reminder permanently'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, reminder);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  static void _showDeleteDialog(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Quick delete with undo option
  static void quickDelete(BuildContext context, Reminder reminder) {
    context.read<ReminderBloc>().add(DeleteReminder(reminder.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder.title} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<ReminderBloc>().add(AddReminder(reminder));
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Edit directly
  static void editReminder(BuildContext context, Reminder reminder) {
    context.push(AppRouter.editReminder, extra: reminder);
  }

  // Toggle complete status
  static void toggleComplete(BuildContext context, Reminder reminder) {
    context.read<ReminderBloc>().add(ToggleReminderComplete(reminder.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reminder.isCompleted
              ? '${reminder.title} marked as active'
              : '${reminder.title} marked as complete',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Similar widget for Recharge actions
class RechargeActions {
  static void showActionSheet(
      BuildContext context, MobileRecharge recharge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              title: const Text('Edit Recharge'),
              subtitle: const Text('Modify recharge details'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.editRecharge, extra: recharge);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text('Delete Recharge'),
              subtitle: const Text('Remove this recharge record'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, recharge);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteDialog(
      BuildContext context, MobileRecharge recharge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recharge'),
        content: Text(
          'Are you sure you want to delete the recharge record for ${recharge.mobileNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RechargeBloc>().add(DeleteRecharge(recharge.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}