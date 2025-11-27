import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfilesLoaded extends ProfileState {
  final List<ProfileModel> profiles;

  const ProfilesLoaded(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class ProfileSelected extends ProfileState {
  final ProfileModel profile;

  const ProfileSelected(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileCreated extends ProfileState {
  final ProfileModel profile;

  const ProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
