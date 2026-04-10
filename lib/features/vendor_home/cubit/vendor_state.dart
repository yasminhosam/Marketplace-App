part of 'vendor_cubit.dart';


abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final UserModel user;
  final VendorStatsModel stats;

  VendorLoaded({required this.user, required this.stats});
}

class VendorError extends VendorState {
  final String message;
  VendorError(this.message);
}