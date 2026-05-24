import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';
import '../providers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _controller = AuthController.create();

  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await _controller.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign up successful. Please verify your email.'),
        ),
      );
      context.go('/auth/login');
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.15),
                  radius: 1.0,
                  colors: [Color(0x1FABD600), AppColors.background],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    children: [
                      const _LogoBlock(),
                      const SizedBox(height: 20),
                      Text(
                        'JOIN THE ELITE',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 58,
                              color: AppColors.primary,
                              letterSpacing: -0.6,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create your account to track your progress.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.75),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('FULL NAME'),
                              const SizedBox(height: 8),
                              _input(
                                controller: _nameController,
                                hint: 'John Doe',
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    (value ?? '').trim().isEmpty
                                    ? 'Enter your full name.'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _label('EMAIL ADDRESS'),
                              const SizedBox(height: 8),
                              _input(
                                controller: _emailController,
                                hint: 'athlete@progressive.com',
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty || !text.contains('@')) {
                                    return 'Enter a valid email.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _label('PASSWORD'),
                              const SizedBox(height: 8),
                              _input(
                                controller: _passwordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                onToggleObscure: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if ((value ?? '').length < 6) {
                                    return 'Password must be at least 6 characters.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _label('CONFIRM PASSWORD'),
                              const SizedBox(height: 8),
                              _input(
                                controller: _confirmController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                onToggleObscure: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              _submitting
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : NeonPrimaryButton(
                                      label: 'SIGN UP',
                                      icon: Icons.arrow_forward,
                                      onPressed: _onSubmit,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 19,
                              ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: Text(
                                  'Log In',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_submitting) _loadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _loadingOverlay() {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textMuted.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                splashRadius: 20,
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 22,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.85)),
        ),
        child: const Center(
          child: Icon(Icons.bolt, color: AppColors.primary, size: 52),
        ),
      ),
    );
  }
}
