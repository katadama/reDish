import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/profile_model.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfiles extends ProfileEvent {
  final bool autoSelect;

  LoadProfiles({this.autoSelect = false});

  @override
  List<Object?> get props => [autoSelect];
}

class CheckProfileStatus extends ProfileEvent {
  final bool autoSelect;

  CheckProfileStatus({this.autoSelect = false});

  @override
  List<Object?> get props => [autoSelect];
}

class SelectProfile extends ProfileEvent {
  final ProfileModel profile;

  SelectProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class CreateProfile extends ProfileEvent {
  final String name;
  final int colorIndex;

  CreateProfile({
    required this.name,
    required this.colorIndex,
  });

  @override
  List<Object?> get props => [name, colorIndex];
}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;

  UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DeleteProfile extends ProfileEvent {
  final String profileId;

  DeleteProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class ResetProfileState extends ProfileEvent {}
