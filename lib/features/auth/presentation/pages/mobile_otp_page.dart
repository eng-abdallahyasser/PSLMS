import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';

class MobileOtpPage extends StatefulWidget {
  const MobileOtpPage({super.key});

  @override
  State<MobileOtpPage> createState() => _MobileOtpPageState();
}

class _MobileOtpPageState extends State<MobileOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _sendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().sendMobileOtp(
            mobileNumber: _phoneController.text.trim(),
          );
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '').split('');
      for (int i = 0; i < digits.length && index + i < 6; i++) {
        _otpControllers[index + i].text = digits[i];
        if (index + i < 5) {
          _otpFocusNodes[index + i + 1].requestFocus();
        } else {
          _otpFocusNodes[index + i].unfocus();
        }
      }
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _otpFocusNodes[index].unfocus();
    }
  }

  void _verify() {
    final otp = _otp;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyMobileOtp(
          mobileNumber: _phoneController.text.trim(),
          otp: otp,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AuthMobileOtpSent) {
            setState(() => _otpSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent to your phone!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is AuthMobileOtpVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone verified! Welcome.'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/dashboard');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.phone_android_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _otpSent ? 'Enter OTP' : 'Verify Phone Number',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _otpSent
                        ? 'Enter the 6-digit code sent to your phone.'
                        : 'Enter your phone number to receive a verification code.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),
                  if (!_otpSent) ...[
                    AppTextField(
                      label: 'Phone Number',
                      hint: '+201234567890',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
                        if (!phoneRegex.hasMatch(value.trim())) {
                          return 'Enter a valid phone with country code';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AppPrimaryButton(
                          label: 'Send OTP',
                          isLoading: state is AuthLoading,
                          onPressed: _sendOtp,
                          icon: Icons.send_outlined,
                        );
                      },
                    ),
                  ],
                  if (_otpSent) ...[
                    // 6-digit OTP input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 52,
                          height: 64,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1565C0),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (value) => _onDigitChanged(index, value),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AppPrimaryButton(
                          label: 'Verify Phone',
                          isLoading: state is AuthLoading,
                          onPressed: _verify,
                          icon: Icons.verified_outlined,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: _sendOtp,
                          child: const Text('Resend'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (!_otpSent)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Back to Sign In'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
