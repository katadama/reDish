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

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;

  const LoginScreen({
    super.key,
    this.prefilledEmail,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _shouldShowSuccessMessage = true;

  @override
  void initState() {
    super.initState();

    if (widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty) {
      emailController.text = widget.prefilledEmail!;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _shouldShowSuccessMessage = false;
      });
      context.read<AuthBloc>().add(SignInEvent(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ));
    }
  }

  void _navigateToRegister() {
    context.read<AuthBloc>().add(ClearAuthErrorEvent());
    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacementNamed(AppRouter.register);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => AppRouter.authRedirect(),
              ),
              (route) => false,
            );
          }
          if (state is AuthError) {
            setState(() {
              _shouldShowSuccessMessage = false;
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthError
              ? FormValidators.formatAuthError(state.message)
              : null;

          final successMessage = widget.prefilledEmail != null &&
                  widget.prefilledEmail!.isNotEmpty &&
                  _shouldShowSuccessMessage &&
                  errorMessage == null
              ? 'Sikeres regisztráció! Kérlek jelentkezz be a fiókodba: ${widget.prefilledEmail}'
              : null;

          final screenHeight = MediaQuery.of(context).size.height;
          return FadeTransition(
            opacity: _fadeAnimation,
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
                          'Bejelentkezés',
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
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: passwordController,
                          labelText: 'Jelszó',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: FormValidators.validatePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !isLoading,
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
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: StyleUtils.getPrimaryButtonStyle(),
                          child: isLoading
                              ? StyleUtils.getLoadingIndicator()
                              : const Text(
                                  'Bejelentkezés',
                                  style: StyleUtils.primaryButtonTextStyle,
                                ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _navigateToRegister,
                          child: const Text(
                            'Nincs még fiókod? Regisztrálj!',
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
