import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/models/reminder.dart';
import '../../../data/repositories/recharge_repository.dart';

// Events
abstract class RechargeEvent extends Equatable {
  const RechargeEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecharges extends RechargeEvent {}

class AddRecharge extends RechargeEvent {
  final MobileRecharge recharge;

  const AddRecharge(this.recharge);

  @override
  List<Object?> get props => [recharge];
}

class UpdateRecharge extends RechargeEvent {
  final MobileRecharge recharge;

  const UpdateRecharge(this.recharge);

  @override
  List<Object?> get props => [recharge];
}

class DeleteRecharge extends RechargeEvent {
  final String id;

  const DeleteRecharge(this.id);

  @override
  List<Object?> get props => [id];
}

// States
abstract class RechargeState extends Equatable {
  const RechargeState();

  @override
  List<Object?> get props => [];
}

class RechargeInitial extends RechargeState {}

class RechargeLoading extends RechargeState {}

class RechargeLoaded extends RechargeState {
  final List<MobileRecharge> recharges;
  final List<MobileRecharge> activeRecharges;
  final List<MobileRecharge> expiringSoonRecharges;
  final List<MobileRecharge> expiredRecharges;

  const RechargeLoaded({
    required this.recharges,
    required this.activeRecharges,
    required this.expiringSoonRecharges,
    required this.expiredRecharges,
  });

  @override
  List<Object?> get props =>
      [recharges, activeRecharges, expiringSoonRecharges, expiredRecharges];
}

class RechargeError extends RechargeState {
  final String message;

  const RechargeError(this.message);

  @override
  List<Object?> get props => [message];
}

class RechargeOperationSuccess extends RechargeState {
  final String message;

  const RechargeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RechargeBloc extends Bloc<RechargeEvent, RechargeState> {
  final RechargeRepository repository;

  RechargeBloc(this.repository) : super(RechargeInitial()) {
    on<LoadRecharges>(_onLoadRecharges);
    on<AddRecharge>(_onAddRecharge);
    on<UpdateRecharge>(_onUpdateRecharge);
    on<DeleteRecharge>(_onDeleteRecharge);
  }

  Future<void> _onLoadRecharges(
      LoadRecharges event,
      Emitter<RechargeState> emit,
      ) async {
    try {
      emit(RechargeLoading());

      final recharges = await repository.getAllRecharges();
      final activeRecharges = await repository.getActiveRecharges();
      final expiringSoonRecharges =
      await repository.getExpiringSoonRecharges();
      final expiredRecharges = await repository.getExpiredRecharges();

      emit(RechargeLoaded(
        recharges: recharges,
        activeRecharges: activeRecharges,
        expiringSoonRecharges: expiringSoonRecharges,
        expiredRecharges: expiredRecharges,
      ));
    } catch (e) {
      emit(RechargeError('Failed to load recharges: ${e.toString()}'));
    }
  }

  Future<void> _onAddRecharge(
      AddRecharge event,
      Emitter<RechargeState> emit,
      ) async {
    try {
      final success = await repository.addRecharge(event.recharge);

      if (success) {
        emit(const RechargeOperationSuccess('Recharge added successfully'));
        add(LoadRecharges());
      } else {
        emit(const RechargeError('Failed to add recharge'));
      }
    } catch (e) {
      emit(RechargeError('Failed to add recharge: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRecharge(
      UpdateRecharge event,
      Emitter<RechargeState> emit,
      ) async {
    try {
      final success = await repository.updateRecharge(event.recharge);

      if (success) {
        emit(const RechargeOperationSuccess('Recharge updated successfully'));
        add(LoadRecharges());
      } else {
        emit(const RechargeError('Failed to update recharge'));
      }
    } catch (e) {
      emit(RechargeError('Failed to update recharge: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRecharge(
      DeleteRecharge event,
      Emitter<RechargeState> emit,
      ) async {
    try {
      final success = await repository.deleteRecharge(event.id);

      if (success) {
        emit(const RechargeOperationSuccess('Recharge deleted successfully'));
        add(LoadRecharges());
      } else {
        emit(const RechargeError('Failed to delete recharge'));
      }
    } catch (e) {
      emit(RechargeError('Failed to delete recharge: ${e.toString()}'));
    }
  }
}