import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_manager.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this._sessionManager, required this._repository})
    : super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileImageUpdateRequested>(_onImageUpdateRequested);
    on<ProfileImageRemoveRequested>(_onImageRemoveRequested);
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
            profile: ProfileData.fromSession(
            user,
            isGuest: _sessionManager.isGuestMode,
          ),
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

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.submitting,
        updateError: null,
      ),
    );
    final result = await _repository.updateMyProfile(
      name: event.name,
      phone: event.phone,
    );
    final user = result.dataOrNull;
    if (user != null) {
      emit(
        state.copyWith(
          updateStatus: ProfileUpdateStatus.success,
          profile: ProfileData.fromSession(
            user,
            isGuest: _sessionManager.isGuestMode,
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        updateError: result.failureOrNull?.message ?? 'Failed to update profile.',
      ),
    );
  }

  Future<void> _onImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.submitting,
        updateError: null,
      ),
    );
    final result = await _repository.updateMyProfileImage(
      imagePath: event.imagePath,
    );
    final user = result.dataOrNull;
    if (user != null) {
      emit(
        state.copyWith(
          updateStatus: ProfileUpdateStatus.success,
          profile: ProfileData.fromSession(
            user,
            isGuest: _sessionManager.isGuestMode,
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        updateError: result.failureOrNull?.message ?? 'Failed to update photo.',
      ),
    );
  }

  Future<void> _onImageRemoveRequested(
    ProfileImageRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.submitting,
        updateError: null,
      ),
    );
    final result = await _repository.removeMyProfileImage();
    final user = result.dataOrNull;
    if (user != null) {
      emit(
        state.copyWith(
          updateStatus: ProfileUpdateStatus.success,
          profile: ProfileData.fromSession(
            user,
            isGuest: _sessionManager.isGuestMode,
          ),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        updateError: result.failureOrNull?.message ?? 'Failed to remove photo.',
      ),
    );
  }}
