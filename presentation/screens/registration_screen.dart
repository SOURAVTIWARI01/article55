import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_voting_firebase/data/models/voter_model.dart';
import 'package:society_voting_firebase/services/auth_service.dart';
import 'package:society_voting_firebase/presentation/screens/voting_dashboard_screen.dart';

final authServiceProvider = Provider((ref) => AuthService());

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _flatController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _isLoading = false;
  bool _isOTPSent = false;

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authServiceProvider).sendOTP(
          phoneNumber: _phoneController.text,
          onCodeSent: (verificationId) {
            setState(() {
              _verificationId = verificationId;
              _isOTPSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully!')),
            );
          },
          onVerificationFailed: (e) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${e.message}')),
            );
          },
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _verifyAndRegister() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await ref.read(authServiceProvider).signInWithOTP(
        _verificationId!,
        _otpController.text,
      );

      if (userCredential.user != null) {
        final voter = VoterModel(
          uid: userCredential.user!.uid,
          name: _nameController.text,
          blockNumber: _blockController.text,
          flatNumber: _flatController.text,
          phoneNumber: _phoneController.text,
          createdAt: DateTime.now(),
        );

        await ref.read(authServiceProvider).registerVoter(voter);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const VotingDashboardScreen()),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('Voter Registration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B3C5D),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.how_to_reg, size: 64, color: Color(0xFF0B3C5D)),
                    const SizedBox(height: 16),
                    const Text(
                      'Resident Verification',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                    ),
                    const SizedBox(height: 32),
                    if (!_isOTPSent) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _blockController,
                              decoration: const InputDecoration(
                                labelText: 'Block',
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _flatController,
                              decoration: const InputDecoration(
                                labelText: 'Flat No',
                                prefixIcon: Icon(Icons.home),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (with +code)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                      ),
                    ] else ...[
                      const Text('OTP sent to your phone. Enter it below:'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8),
                        decoration: const InputDecoration(
                          labelText: 'SMS Code',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.length != 6 ? 'Enter 6-digit OTP' : null,
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isOTPSent ? _verifyAndRegister : _sendOTP),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B3C5D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isOTPSent ? 'Verify & Register' : 'Send OTP'),
                      ),
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
}
