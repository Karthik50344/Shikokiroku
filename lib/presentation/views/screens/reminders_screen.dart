import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shikokiroku/presentation/views/widgets/reminder_action.dart';
import '../../../domain/models/reminder.dart';
import '../../bloc/reminder/reminder_bloc.dart';
import '../../router/app_router.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              title: const Text('Reminders', style: TextStyle(color: Colors.purple),),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.purple,),
                onPressed: () => context.go(AppRouter.home),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.purple,),
                  onPressed: () => _showSearchDialog(context),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Overdue'),
                ],
              ),
            ),
          ];
        },
        body: BlocListener<ReminderBloc, ReminderState>(
          listener: (context, state) {
            if (state is ReminderOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ReminderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRemindersList(context, ReminderFilter.active),
              _buildRemindersList(context, ReminderFilter.completed),
              _buildRemindersList(context, ReminderFilter.overdue),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addReminder),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, ReminderFilter filter) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is ReminderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReminderLoaded) {
          List<Reminder> reminders;
          switch (filter) {
            case ReminderFilter.active:
              reminders = state.activeReminders;
              break;
            case ReminderFilter.completed:
              reminders = state.completedReminders;
              break;
            case ReminderFilter.overdue:
              reminders = state.overdueReminders;
              break;
          }

          if (reminders.isEmpty) {
            return _buildEmptyState(filter);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              return _buildReminderCard(context, reminders[index]);
            },
          );
        }

        return _buildEmptyState(filter);
      },
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => ReminderActions.editReminder(context, reminder),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => ReminderActions.quickDelete(context, reminder),
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
          onTap: () => ReminderActions.showActionSheet(context, reminder),
          onLongPress: () => ReminderActions.showActionSheet(context, reminder),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: reminder.isCompleted,
                  onChanged: (value) {
                    context
                        .read<ReminderBloc>()
                        .add(ToggleReminderComplete(reminder.id));
                  },
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (reminder.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: reminder.category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  reminder.category.icon,
                                  size: 14,
                                  color: reminder.category.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  reminder.category.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: reminder.category.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, h:mm a')
                                .format(reminder.dateTime),
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
                Icon(
                  Icons.chevron_right,
                  color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ReminderFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case ReminderFilter.active:
        message = 'No active reminders';
        icon = Icons.notifications_none;
        break;
      case ReminderFilter.completed:
        message = 'No completed reminders';
        icon = Icons.check_circle_outline;
        break;
      case ReminderFilter.overdue:
        message = 'No overdue reminders';
        icon = Icons.warning_amber_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Reminders'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search query',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            context.read<ReminderBloc>().add(SearchReminders(value));
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ReminderBloc>().add(LoadReminders());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

enum ReminderFilter { active, completed, overdue }