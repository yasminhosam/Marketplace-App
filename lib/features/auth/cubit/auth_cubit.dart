import 'dart:developer';
import 'package:marketplace_app/core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import 'auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  void _emitAuthenticated(UserModel user) {
    if (user.role == 'vendor') {
      emit(AuthenticatedVendor(user));
    } else {
      emit(AuthenticatedClient(user));
    }
  }

  void checkAuthStatus() async {
    final firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      emit(AuthUnAuthenticated());
      return;
    }
    try{
    await firebaseUser.reload();

    if (!firebaseUser.emailVerified) {
      emit(AuthEmailNotVerified());
      return;
    }
    emit(AuthLoading());

      final user = await _authService.getUser(firebaseUser.uid);
      if (user == null) {
        emit(AuthUnAuthenticated());
      } else {
        _emitAuthenticated(user);
      }
    } catch (e) {
      emit(AuthError("Failed to load user data."));
      log("Auth status check failed: $e", name: "AuthCubit");
    }
  }
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final user = await _authService.signIn(email: email, password: password);

      if (user == null) {
        emit(AuthEmailNotVerified());
        return;
      }

      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      log("Login failed $e",name: "AuthCubit");
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? storeName,
    String? storeDescription,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authService.register(
        userName: username,
        email: email,
        password: password,
        role: role,
        storeName: storeName,
        storeDescription: storeDescription
      );

      if (user == null) {
        emit(AuthError("Registration failed. Please try again."));
        log("user is null",name: "AuthCubit");
        return;
      }


      emit(AuthEmailNotVerified());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      log("Register failed $e",name: "AuthCubit");
    }
  }

  Future<void> resetPassword({required String email}) async {
    if (email.isEmpty) {
      emit(AuthError("Please enter your email address first."));
      return;
    }
    emit(AuthLoading());
    try {
      await _authService.resetPassword(email: email);
      emit(AuthPasswordResetSent());
    } on Exception catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      emit(AuthError("Failed to send reset email. Please try again."));
      log("Rest password failed $e",name: "AuthCubit");
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authService.signOut();
    emit(AuthUnAuthenticated());
  }
}
