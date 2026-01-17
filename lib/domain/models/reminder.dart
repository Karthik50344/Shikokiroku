import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Reminder Model
class Reminder extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final ReminderCategory category;
  final RepeatType repeat;
  final bool isCompleted;
  final bool notificationEnabled;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.category = ReminderCategory.other,
    this.repeat = RepeatType.none,
    this.isCompleted = false,
    this.notificationEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'category': category.index,
      'repeat': repeat.index,
      'isCompleted': isCompleted,
      'notificationEnabled': notificationEnabled,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      category: ReminderCategory.values[json['category']],
      repeat: RepeatType.values[json['repeat']],
      isCompleted: json['isCompleted'],
      notificationEnabled: json['notificationEnabled'],
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    ReminderCategory? category,
    RepeatType? repeat,
    bool? isCompleted,
    bool? notificationEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dateTime,
    category,
    repeat,
    isCompleted,
    notificationEnabled,
  ];
}

// Mobile Recharge Model
class MobileRecharge extends Equatable {
  final String id;
  final String mobileNumber;
  final String operator;
  final double amount;
  final DateTime rechargeDate;
  final int validityDays;
  final DateTime expiryDate;
  final bool reminderEnabled;
  final int reminderDaysBefore;

  const MobileRecharge({
    required this.id,
    required this.mobileNumber,
    required this.operator,
    required this.amount,
    required this.rechargeDate,
    required this.validityDays,
    required this.expiryDate,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'operator': operator,
      'amount': amount,
      'rechargeDate': rechargeDate.toIso8601String(),
      'validityDays': validityDays,
      'expiryDate': expiryDate.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

  factory MobileRecharge.fromJson(Map<String, dynamic> json) {
    return MobileRecharge(
      id: json['id'],
      mobileNumber: json['mobileNumber'],
      operator: json['operator'],
      amount: json['amount'],
      rechargeDate: DateTime.parse(json['rechargeDate']),
      validityDays: json['validityDays'],
      expiryDate: DateTime.parse(json['expiryDate']),
      reminderEnabled: json['reminderEnabled'],
      reminderDaysBefore: json['reminderDaysBefore'],
    );
  }

  int get daysRemaining {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    return daysRemaining <= reminderDaysBefore && daysRemaining >= 0;
  }

  bool get isExpired {
    return daysRemaining < 0;
  }

  @override
  List<Object?> get props => [
    id,
    mobileNumber,
    operator,
    amount,
    rechargeDate,
    validityDays,
    expiryDate,
    reminderEnabled,
    reminderDaysBefore,
  ];
}

// Enums
enum ReminderCategory {
  personal,
  work,
  health,
  shopping,
  bills,
  other,
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

// Extensions
extension ReminderCategoryExtension on ReminderCategory {
  String get name {
    switch (this) {
      case ReminderCategory.personal:
        return 'Personal';
      case ReminderCategory.work:
        return 'Work';
      case ReminderCategory.health:
        return 'Health';
      case ReminderCategory.shopping:
        return 'Shopping';
      case ReminderCategory.bills:
        return 'Bills';
      case ReminderCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderCategory.personal:
        return Icons.person;
      case ReminderCategory.work:
        return Icons.work;
      case ReminderCategory.health:
        return Icons.local_hospital;
      case ReminderCategory.shopping:
        return Icons.shopping_cart;
      case ReminderCategory.bills:
        return Icons.receipt;
      case ReminderCategory.other:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case ReminderCategory.personal:
        return Colors.blue;
      case ReminderCategory.work:
        return Colors.orange;
      case ReminderCategory.health:
        return Colors.red;
      case ReminderCategory.shopping:
        return Colors.green;
      case ReminderCategory.bills:
        return Colors.purple;
      case ReminderCategory.other:
        return Colors.grey;
    }
  }
}

extension RepeatTypeExtension on RepeatType {
  String get name {
    switch (this) {
      case RepeatType.none:
        return 'No Repeat';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
    }
  }
}