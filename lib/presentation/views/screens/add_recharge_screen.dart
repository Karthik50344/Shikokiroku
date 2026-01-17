import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/reminder.dart';
import '../../bloc/recharge/recharge_bloc.dart';

class AddRechargeScreen extends StatefulWidget {
  final MobileRecharge? recharge;

  const AddRechargeScreen({super.key, this.recharge});

  @override
  State<AddRechargeScreen> createState() => _AddRechargeScreenState();
}

class _AddRechargeScreenState extends State<AddRechargeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mobileController;
  late TextEditingController _amountController;
  late TextEditingController _validityController;

  late String _selectedOperator;
  late DateTime _rechargeDate;
  late bool _reminderEnabled;
  late int _reminderDaysBefore;

  final List<String> _operators = [
    'Jio',
    'Airtel',
    'Vi (Vodafone Idea)',
    'BSNL',
    'MTNL',
    'Other',
  ];

  bool get _isEditing => widget.recharge != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _mobileController =
          TextEditingController(text: widget.recharge!.mobileNumber);
      _amountController =
          TextEditingController(text: widget.recharge!.amount.toString());
      _validityController =
          TextEditingController(text: widget.recharge!.validityDays.toString());
      _selectedOperator = widget.recharge!.operator;
      _rechargeDate = widget.recharge!.rechargeDate;
      _reminderEnabled = widget.recharge!.reminderEnabled;
      _reminderDaysBefore = widget.recharge!.reminderDaysBefore;
    } else {
      _mobileController = TextEditingController();
      _amountController = TextEditingController();
      _validityController = TextEditingController();
      _selectedOperator = _operators.first;
      _rechargeDate = DateTime.now();
      _reminderEnabled = true;
      _reminderDaysBefore = 3;
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _amountController.dispose();
    _validityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recharge' : 'Add Recharge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecharge,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<RechargeBloc, RechargeState>(
        listener: (context, state) {
          if (state is RechargeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          } else if (state is RechargeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter 10-digit mobile number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedOperator,
                decoration: const InputDecoration(
                  labelText: 'Operator',
                  prefixIcon: Icon(Icons.sim_card),
                  border: OutlineInputBorder(),
                ),
                items: _operators.map((operator) {
                  return DropdownMenuItem(
                    value: operator,
                    child: Text(operator),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOperator = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Recharge Amount',
                  hintText: 'Enter amount in ₹',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recharge amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Recharge Date'),
                  subtitle: Text(
                      DateFormat('EEEE, MMMM d, y').format(_rechargeDate)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _validityController,
                decoration: const InputDecoration(
                  labelText: 'Validity (Days)',
                  hintText: 'Enter validity in days',
                  prefixIcon: Icon(Icons.event_available),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to show expiry info
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter validity days';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return 'Please enter valid days';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_validityController.text.isNotEmpty &&
                  int.tryParse(_validityController.text) != null)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expiry Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expiry Date: ${DateFormat('EEEE, MMMM d, y').format(_calculateExpiryDate())}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Reminder Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Reminder'),
                      subtitle: const Text('Get notified before expiry'),
                      secondary: const Icon(Icons.notifications),
                      value: _reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          _reminderEnabled = value;
                        });
                      },
                    ),
                    if (_reminderEnabled) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remind me $_reminderDaysBefore days before expiry',
                              style:
                              const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Slider(
                              value: _reminderDaysBefore.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: '$_reminderDaysBefore days',
                              onChanged: (value) {
                                setState(() {
                                  _reminderDaysBefore = value.toInt();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saveRecharge,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Update Recharge' : 'Add Recharge'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _calculateExpiryDate() {
    final validityDays = int.tryParse(_validityController.text) ?? 0;
    return _rechargeDate.add(Duration(days: validityDays));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _rechargeDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _rechargeDate) {
      setState(() {
        _rechargeDate = picked;
      });
    }
  }

  void _saveRecharge() {
    if (_formKey.currentState!.validate()) {
      final validityDays = int.parse(_validityController.text);
      final expiryDate = _rechargeDate.add(Duration(days: validityDays));

      final recharge = MobileRecharge(
        id: _isEditing ? widget.recharge!.id : const Uuid().v4(),
        mobileNumber: _mobileController.text,
        operator: _selectedOperator,
        amount: double.parse(_amountController.text),
        rechargeDate: _rechargeDate,
        validityDays: validityDays,
        expiryDate: expiryDate,
        reminderEnabled: _reminderEnabled,
        reminderDaysBefore: _reminderDaysBefore,
      );

      if (_isEditing) {
        context.read<RechargeBloc>().add(UpdateRecharge(recharge));
      } else {
        context.read<RechargeBloc>().add(AddRecharge(recharge));
      }
    }
  }
}