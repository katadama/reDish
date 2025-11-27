import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/auth/auth_event.dart';
import 'package:coo_list/logic/auth/auth_state.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/presentation/widgets/profile_avatar.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsScreen extends StatefulWidget {
  static const String routeName = '/account-settings';

  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isLoadingProfile = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    setState(() {
      _isLoadingProfile = true;
    });

    final profileBloc = context.read<ProfileBloc>();
    final profileState = profileBloc.state;
    if (profileState is! ProfileSelected) {
      final prefs = await SharedPreferences.getInstance();
      final lastProfileId = prefs.getString(AppRouter.lastSelectedProfileKey);

      if (lastProfileId != null && mounted) {
        profileBloc.add(CheckProfileStatus(autoSelect: true));
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _handleLogout(BuildContext context) {
    setState(() {
      _isLoggingOut = true;
    });
    context.read<ProfileBloc>().add(ResetProfileState());
    context.read<AuthBloc>().add(SignOutEvent());
  }

  void _switchProfile(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRouter.profileSelection);
  }

  void _navigateToStatistics(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.statistics);
  }

  void _navigateToBin(BuildContext context) {
    Navigator.of(context).pushNamed(AppRouter.bin);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (_isLoadingProfile || state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF34744),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: SizedBox()),
                if (state is ProfileSelected) ...[
                  Center(
                    child: Column(
                      children: [
                        ProfileAvatar(
                          profile: state.profile,
                          size: 80,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.profile.name,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Beállítások',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(),
                const ListTile(
                  minTileHeight: 10,
                  leading: Icon(Icons.settings_outlined, color: Colors.grey),
                  title: Text('Profil Szerkesztése',
                      style: TextStyle(color: Colors.grey)),
                  subtitle: Text('Profil Szerkesztése',
                      style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                ),
                const Divider(),
                ListTile(
                  minTileHeight: 10,
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Statisztikák'),
                  subtitle: const Text('Fiók és termékek statisztikái'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToStatistics(context),
                ),
                const Divider(),

                ListTile(
                  minTileHeight: 10,
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Kuka'),
                  subtitle: const Text('Törölt termékek megtekintése'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToBin(context),
                ),
                const Divider(),

                ListTile(
                  minTileHeight: 10,
                  leading: const Icon(Icons.person),
                  title: const Text('Profilok'),
                  subtitle: const Text('Másik profilra váltás'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _switchProfile(context),
                ),
                const Divider(),

                ListTile(
                  minTileHeight: 10,
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Kijelentkezés',
                      style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Kijelentkezés a fiókból'),
                  onTap: _isLoggingOut ? null : () => _handleLogout(context),
                  trailing: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
