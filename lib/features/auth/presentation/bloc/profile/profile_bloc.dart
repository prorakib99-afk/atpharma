import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_manager.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this._sessionManager, required this._repository})
    : super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
  }

  final SessionManager _sessionManager;
  final AuthRepository _repository;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    if (!_sessionManager.isGuestMode && _sessionManager.hasAccessToken) {
      final result = await _repository.getMyProfile();
      final user = result.dataOrNull;
      if (user != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            profile: ProfileData.fromSession(user, isGuest: false),
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        status: ProfileStatus.success,
        profile: ProfileData.fromSession(
          _sessionManager.currentUser,
          isGuest: _sessionManager.isGuestMode,
        ),
      ),
    );
  }
}
