import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/repositories/profile_repository.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coo_list/config/app_router.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository})
      : super(const ProfileInitial()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<CheckProfileStatus>(_onCheckProfileStatus);
    on<SelectProfile>(_onSelectProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<ResetProfileState>(_onResetProfileState);
  }

  Future<void> _onLoadProfiles(
      LoadProfiles event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final profiles = await profileRepository.getProfiles();

      if (profiles.isNotEmpty && event.autoSelect) {
        final prefs = await SharedPreferences.getInstance();
        final lastProfileId = prefs.getString(AppRouter.lastSelectedProfileKey);

        if (lastProfileId != null) {
          try {
            final lastProfile = profiles.firstWhere(
              (profile) => profile.id == lastProfileId,
              orElse: () => profiles.first,
            );

            emit(ProfileSelected(lastProfile));
            return;
          } catch (e) {
            emit(ProfileError('Nem sikerült kiválasztani a profilt: $e'));
          }
        }
      }

      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileError('Nem sikerült betölteni a profilokat: $e'));
    }
  }

  Future<void> _onCheckProfileStatus(
      CheckProfileStatus event, Emitter<ProfileState> emit) async {
    if (state is ProfileSelected && event.autoSelect) {
      return;
    }

    emit(const ProfileLoading());
    try {
      final hasProfiles = await profileRepository.hasProfiles();
      if (hasProfiles) {
        add(LoadProfiles(autoSelect: event.autoSelect));
      } else {
        emit(const ProfilesLoaded([]));
      }
    } catch (e) {
      emit(ProfileError('Nem sikerült ellenőrizni a profil állapotot: $e'));
    }
  }

  Future<void> _onSelectProfile(
      SelectProfile event, Emitter<ProfileState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppRouter.lastSelectedProfileKey, event.profile.id);

      emit(ProfileSelected(event.profile));
    } catch (e) {
      emit(ProfileError('Nem sikerült kiválasztani a profilt: $e'));
    }
  }

  Future<void> _onCreateProfile(
      CreateProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      final profile = await profileRepository.createProfile(
        name: event.name,
        colorIndex: event.colorIndex,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppRouter.lastSelectedProfileKey, profile.id);

      emit(ProfileCreated(profile));
      emit(ProfileSelected(profile));
    } catch (e) {
      emit(ProfileError('Nem sikerült létrehozni a profilt: $e'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      await profileRepository.updateProfile(event.profile);
      add(LoadProfiles());
    } catch (e) {
      emit(ProfileError('Nem sikerült frissíteni a profilt: $e'));
    }
  }

  Future<void> _onDeleteProfile(
      DeleteProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      await profileRepository.deleteProfile(event.profileId);
      add(LoadProfiles());
    } catch (e) {
      emit(ProfileError('Nem sikerült törölni a profilt: $e'));
    }
  }

  Future<void> _onResetProfileState(
      ResetProfileState event, Emitter<ProfileState> emit) async {
    emit(const ProfileInitial());
  }
}
