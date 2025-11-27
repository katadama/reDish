import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/auth/auth_event.dart';
import 'package:coo_list/logic/auth/auth_state.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:coo_list/utils/form_validators.dart';
import 'package:coo_list/utils/style_utils.dart';
import 'package:coo_list/presentation/widgets/error_message.dart';
import 'package:coo_list/presentation/widgets/success_message.dart';
import 'package:coo_list/presentation/widgets/title_with_logo.dart';
import 'package:coo_list/presentation/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(SignUpEvent(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ));
    }
  }

  void _navigateToLogin(String? email) {
    final currentState = context.read<AuthBloc>().state;
    if (currentState is! RegistrationSuccess) {
      context.read<AuthBloc>().add(ClearAuthErrorEvent());
    }
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacementNamed(
        AppRouter.login,
        arguments: {'prefilledEmail': email},
      );
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _navigateToLogin(state.email);
              }
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isRegistrationSuccess = state is RegistrationSuccess;
          final errorMessage = state is AuthError
              ? FormValidators.formatAuthError(state.message)
              : null;
          final successMessage = state is RegistrationSuccess
              ? 'Regisztráció sikeres volt! Kérlek jelentkezz be a fiókodba: ${state.email}'
              : null;
          final registeredEmail =
              state is RegistrationSuccess ? state.email : null;

          final screenHeight = MediaQuery.of(context).size.height;
          return SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.13),
                        const TitleWithLogo(),
                        SizedBox(height: screenHeight * 0.06),
                        const Text(
                          'Regisztráció',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          controller: emailController,
                          labelText: 'Email cím',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !isLoading && !isRegistrationSuccess,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Jelszó',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: FormValidators.validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !isLoading && !isRegistrationSuccess,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: confirmPasswordController,
                          labelText: 'Jelszó megerősítése',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) =>
                              FormValidators.validateConfirmPassword(
                            value,
                            passwordController.text,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !isLoading && !isRegistrationSuccess,
                        ),
                        const SizedBox(height: 12),
                        ErrorMessage(
                          message: errorMessage ?? '',
                          isVisible: errorMessage != null,
                        ),
                        SuccessMessage(
                          message: successMessage ?? '',
                          isVisible: successMessage != null,
                        ),
                        const SizedBox(height: 24),
                        if (!isRegistrationSuccess)
                          ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: StyleUtils.getPrimaryButtonStyle(),
                            child: isLoading
                                ? StyleUtils.getLoadingIndicator()
                                : const Text(
                                    'Regisztráció',
                                    style: StyleUtils.primaryButtonTextStyle,
                                  ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _navigateToLogin(registeredEmail),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Vissza a bejelentkezéshez',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (!isRegistrationSuccess)
                          TextButton(
                            onPressed:
                                isLoading ? null : () => _navigateToLogin(null),
                            child: const Text(
                              'Már van fiókod? Jelentkezz be!',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ),
                      ],
                    ),
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
