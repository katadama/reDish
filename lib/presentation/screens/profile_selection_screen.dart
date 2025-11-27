import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/profile_model.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/auth/auth_event.dart';
import 'package:coo_list/logic/auth/auth_state.dart';
import 'package:coo_list/presentation/widgets/profile_avatar.dart';
import 'package:coo_list/presentation/screens/profile_creation_screen.dart';
import 'package:coo_list/config/app_router.dart';

class ProfileSelectionScreen extends StatefulWidget {
  static const String routeName = '/profile-selection';

  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfiles(autoSelect: false));
  }

  void _handleLogout() {
    setState(() {
      _isLoggingOut = true;
    });
    context.read<ProfileBloc>().add(ResetProfileState());
    context.read<AuthBloc>().add(SignOutEvent());
  }

  void _selectProfile(BuildContext context, ProfileModel profile) {
    context.read<ProfileBloc>().add(SelectProfile(profile));
    Navigator.of(context).pushReplacementNamed(AppRouter.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profilok',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          _isLoggingOut
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _handleLogout,
                  tooltip: 'Kijelentkezés',
                ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.login,
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          return BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF424242),
                duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF34744),
                  ),
                );
              } else if (state is ProfilesLoaded) {
                return _buildProfileSelectionUI(context, state.profiles);
              } else if (state is ProfileSelected) {
                return const SizedBox.shrink();
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF34744),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileSelectionUI(
      BuildContext context, List<ProfileModel> profiles) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: profiles.length + (profiles.length < 8 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == profiles.length && profiles.length < 8) {
                    return _buildAddProfileButton(context);
                  }

                  final profile = profiles[index];
                  return _buildProfileItem(context, profile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, ProfileModel profile) {
    return Column(
      children: [
        Expanded(
          child: ProfileAvatar(
            profile: profile,
            onTap: () => _selectProfile(context, profile),
          ),
        ),
        const SizedBox(height: 0),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAddProfileButton(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ProfileAvatar(
            isAddButton: true,
            onTap: () {
              Navigator.of(context).pushNamed(ProfileCreationScreen.routeName);
            },
          ),
        ),
        const SizedBox(height: 0),
        const Text(
          'Profil hozzáadása',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
