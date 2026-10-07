import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/password_strength_indicator.dart';
import 'package:victus_app/core/utils/validators.dart';
import 'package:victus_app/core/utils/haptics.dart';
import 'package:victus_app/features/auth/domain/entities/auth_state.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signup() async {
    Haptics.selectionTap();
    if (_formKey.currentState!.validate()) {
      await ref.read(authStateProvider.notifier).signup(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authStateProvider, (prev, next) {
      if (next is AuthErrorState) {
        Haptics.errorTap();
      } else if (next is Authenticated || next is NeedsPanelLink) {
        Haptics.successTap();
        context.go('/verify-email'); // Assuming sign up requires verification
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started with VictusCloud',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                if (authState is AuthErrorState)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      authState.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                AuthFormField(
                  controller: _nameController,
                  label: 'Display Name',
                  icon: Icons.person_outline,
                  validator: (val) =>
                      Validators.isNotEmpty(val ?? '') ? null : 'Required',
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      Validators.isValidEmail(val ?? '') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  onChanged: (val) => setState(() {}),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                  validator: (val) =>
                      Validators.isValidPassword(val ?? '') ? null : 'Password too weak',
                ),
                const SizedBox(height: 8),
                PasswordStrengthIndicator(password: _passwordController.text),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _confirmController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  validator: (val) {
                    if (val != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text.rich(
                  TextSpan(
                    text: 'By signing up, you agree to our ',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white54),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
