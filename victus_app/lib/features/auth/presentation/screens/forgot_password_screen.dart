import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:victus_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:victus_app/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:victus_app/core/utils/validators.dart';
import 'package:victus_app/core/utils/haptics.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSuccess = false;
  bool _isLoading = false;

  void _sendReset() async {
    if (!Validators.isValidEmail(_emailController.text)) return;
    
    Haptics.selectionTap();
    setState(() => _isLoading = true);
    
    await ref.read(authStateProvider.notifier).resetPassword(_emailController.text.trim());
    
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSuccess 
                ? 'We have sent a password reset link to your email.'
                : 'Enter your email address and we will send you a link to reset your password.',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            if (!_isSuccess) ...[
              AuthFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text(
                        'Send reset link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Back to login'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
