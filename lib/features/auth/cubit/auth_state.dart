sealed class AuthState {}

class AuthInitial extends AuthState{}
class AuthLoading extends AuthState{}
class AuthenticatedClient extends AuthState {}
class AuthenticatedVendor extends AuthState {}
class AuthEmailNotVerified extends AuthState{}
class AuthUnAuthenticated extends AuthState{}
class AuthPasswordResetSent extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
