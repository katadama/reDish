import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_state.dart';

class ProfileValidator {
  ProfileValidator._();

  static String? validateProfile(ProfileBloc profileBloc) {
    final profileState = profileBloc.state;
    
    if (profileState is! ProfileSelected) {
      return 'Error: Nincs profil kiválasztva';
    }

    final String profileId = profileState.profile.id;
    if (profileId.isEmpty) {
      return 'Error: Hibás profile ID';
    }

    return null;
  }

  static String? getProfileId(ProfileBloc profileBloc) {
    final profileState = profileBloc.state;
    
    if (profileState is! ProfileSelected) {
      return null;
    }

    final String profileId = profileState.profile.id;
    if (profileId.isEmpty) {
      return null;
    }

    return profileId;
  }
}
