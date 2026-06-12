import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../cores/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String? email;

  const OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+60');
  final _otpController = TextEditingController();
  bool _codeSent = false;

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendSecondFactorCode(
      _phoneController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _codeSent = success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '2FA code sent to ${_phoneController.text.trim()}.'
              : auth.error ?? 'Unable to send 2FA code.',
        ),
        backgroundColor: success
            ? AppColors.successColor
            : AppColors.errorColor,
      ),
    );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the 6-digit 2FA code.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(code);

    if (!mounted) return;

    if (success) {
      context.goNamed('home');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error ?? 'Invalid 2FA code.'),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.pendingEmail ?? widget.email ?? 'your account';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.goNamed('login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.phonelink_lock_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Two-Factor Verification',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confirm the SMS code for $email.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_iphone_rounded),
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (!RegExp(r'^\+\d{8,15}$').hasMatch(phone)) {
                          return 'Use international format, for example +60123456789.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: auth.isLoading ? null : _sendCode,
                      icon: const Icon(Icons.sms_outlined),
                      label: Text(
                        _codeSent ? 'Send another code' : 'Send code',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      enabled: _codeSent,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: '6-digit code',
                        prefixIcon: Icon(Icons.pin_outlined),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: auth.isLoading || !_codeSent
                          ? null
                          : _verifyCode,
                      icon: auth.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_rounded),
                      label: const Text('Verify and continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
