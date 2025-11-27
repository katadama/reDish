import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/presentation/widgets/profile_avatar.dart';
import 'package:coo_list/utils/profile_colors.dart';
import 'package:coo_list/config/app_router.dart';

class ProfileCreationScreen extends StatefulWidget {
  static const String routeName = '/profile-creation';

  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            CreateProfile(
              name: _nameController.text.trim(),
              colorIndex: _selectedColorIndex,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            bool showBack = false;
            if (state is ProfilesLoaded && state.profiles.isNotEmpty) {
              showBack = true;
            }
            return AppBar(
              title: const Text(
                'Profil készítése',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: showBack
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
            );
          },
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSelected) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.main,
              (route) => false,
            );
          } else if (state is ProfileError) {
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
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ProfileAvatar(
                              initial: _nameController.text.isNotEmpty
                                  ? _nameController.text[0].toUpperCase()
                                  : '?',
                              color: ProfileColors.getColorByIndex(
                                  _selectedColorIndex),
                              size: 100,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Profil Neve',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kérlek írd be a Profil nevét';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Válasz színt a profilodnak',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000),
                          fontFamily: 'SF Pro',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: ProfileColors.colors.length,
                          itemBuilder: (context, index) {
                            final color = ProfileColors.colors[index];
                            final isSelected = index == _selectedColorIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColorIndex = index;
                                });
                              },
                              child: Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.rectangle,
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color.fromARGB(
                                                255, 235, 235, 235),
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            state is ProfileLoading ? null : _createProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF34744),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(
                            color:
                                const Color(0xFFF2F3FA).withValues(alpha: 0.5),
                            width: 2,
                          ),
                          elevation: 2,
                        ),
                        child: state is ProfileLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Profil hozzáadása',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
