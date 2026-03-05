import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/locator.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 45;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _didAutoVerify = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendSeconds > 0) {
        setState(() => _resendSeconds--);
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 6) {
      // User pasted a 6-digit OTP
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all 6 filled — but defer to next frame so text updates settle
    if (_otp.length == 6 && !_didAutoVerify) {
      _didAutoVerify = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
    }
  }

  Future<void> _verify() async {
    final otp = _otp;
    if (otp.length != 6) {
      setState(() => _didAutoVerify = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final auth = locator<AuthService>();
      final success = await auth.verifyOtp(widget.phone, otp);
      if (!success) throw Exception('Invalid OTP');
      if (!mounted) return;

      final hasProfile = await auth.hasProfile();
      if (!mounted) return;
      hasProfile ? context.go('/home') : context.go('/setup');
    } catch (e) {
      if (mounted) {
        // Clear boxes on failure
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
        setState(() {
          _isVerifying = false;
          _didAutoVerify = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Incorrect OTP. Please try again.'),
            backgroundColor: AppColors.emergencyCrimson,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _resendSeconds = 45;
      _didAutoVerify = false;
    });
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    try {
      await locator<AuthService>().signInWithPhone(widget.phone);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent again!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to resend: $e')));
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format display phone: +91XXXXXXXXXX → +91 XXXXX XXXXX
    final display = widget.phone.length > 3
        ? '${widget.phone.substring(0, 3)} ${widget.phone.substring(3)}'
        : widget.phone;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Enter OTP', style: AppTextStyles.titleLarge)
                  .animate().fadeIn(),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium,
                  children: [
                    const TextSpan(text: 'Sent to '),
                    TextSpan(
                      text: display,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.saffronAmber,
                              fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 36),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46,
                    height: 54,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: i == 0 ? 6 : 1, // allow paste on first box
                      style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.saffronAmber),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.mutedSteel),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.mutedSteel),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.saffronAmber, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.elevatedGraphite,
                      ),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  ).animate().fadeIn(delay: (100 + i * 50).ms).slideY(begin: 0.3);
                }),
              ),
              const SizedBox(height: 28),

              // Resend row
              Center(
                child: _resendSeconds > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 14, color: AppColors.mutedFog),
                          const SizedBox(width: 6),
                          Text(
                            'Resend in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: _isResending ? null : _resend,
                        icon: const Icon(Icons.refresh_rounded,
                            size: 16, color: AppColors.saffronAmber),
                        label: Text(
                          _isResending ? 'Sending…' : 'Resend OTP',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.saffronAmber),
                        ),
                      ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: (_isVerifying || _isResending) ? null : _verify,
                child: _isVerifying
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.midnightNavy),
                      )
                    : const Text('Verify & Continue →'),
              ).animate().fadeIn(delay: 560.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
