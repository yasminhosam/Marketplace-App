import 'package:marketplace_app/core/services/auth_service.dart';

import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  void checkAuthStatus()async{
    final user = _authService.currentUser;
    if(user== null){
      emit(AuthUnAuthenticated());
    }else{
      await user.reload();
      if(user.emailVerified){
        _fetchUserRole(user.uid);
      }else{
        emit(AuthEmailNotVerified());
      }
    }
  }

  void _fetchUserRole(String uid) async {
    emit(AuthLoading());
    try {
      String? role = await _authService.getUserRole(uid);
      if (role == 'vendor')
        emit(AuthenticatedVendor());
      else
        emit(AuthenticatedClient());
    } catch (e) {
      emit(AuthError("Failed to fetch role"));
    }
  }
  void checkEmailVerified() async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(AuthUnAuthenticated());
      return;
    }
    await user.reload();
    if (user.emailVerified) {
       _fetchUserRole(user.uid);
    } else {
      emit(AuthEmailNotVerified());
    }
  }

  void login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final user = await _authService.signIn(email: email, password: password);

      if (user == null) {
        emit(AuthError("Invalid email or password"));
        return;
      }

      await user.reload(); // If this throws an error, the catch block catches it

      if (!user.emailVerified) {
        emit(AuthEmailNotVerified());
        return;
      }

      _fetchUserRole(user.uid);

    } catch (e) {
      //  If anything crashes, stop the spinner and show the error.
      emit(AuthError("Login failed. Please try again. "));
    }
  }

  void register({
    required String username,
    required String email,
    required String password,
    required String role
})async {
    emit(AuthLoading());
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        role: role,
      );

      if (user == null) {
        emit(AuthError("Registration failed. Please try again."));
        return;
      }

      await _authService.updateUsername(username: username);
      emit(AuthEmailNotVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
    }
  void resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await _authService.resetPassword(email: email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError("Failed to send reset email. Please try again."));
    }
  }


    void logout() async{
      emit(AuthLoading());
    await _authService.signOut();
    emit(AuthUnAuthenticated());
    }
  }

