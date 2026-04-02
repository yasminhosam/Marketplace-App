import 'package:marketplace_app/core/models/user_model.dart';

sealed class AuthState {}

class AuthInitial extends AuthState{}
class AuthLoading extends AuthState{}
class AuthenticatedClient extends AuthState {
  final UserModel user;
  AuthenticatedClient(this.user);
}
class AuthenticatedVendor extends AuthState {
  final UserModel user;
  AuthenticatedVendor(this.user);
}
class AuthEmailNotVerified extends AuthState{}
class AuthUnAuthenticated extends AuthState{}
class AuthPasswordResetSent extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
