// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success = false;

    try {
      if (isLogin) {
        success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        success = await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _roleController.text.trim(),
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isLogin ? "Welcome back!" : "Profile created successfully!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication failed. Please check your credentials.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("CONNECTION ERROR: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Header
              Icon(Icons.psychology, size: 80, color: gold),
              const SizedBox(height: 24),
              Text(
                'PATHVISION OS',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: 4,
                ),
              ),
              Text(
                'SYSTEM ACCESS INTERFACE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: textDim,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),

              // Form
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gold.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: gold.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isLogin ? 'AUTH_LOGIN' : 'CREATE_PROFILE',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      if (!isLogin) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'FULL NAME',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _roleController,
                          label: 'POSITION / ROLE',
                          icon: Icons.work_outline,
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildTextField(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'SECURITY TOKEN',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),

                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: gold,
                                foregroundColor: bgPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(bgPrimary),
                                    ),
                                  )
                                : Text(
                                    isLogin ? 'EXECUTE LOGIN' : 'INITIALIZE PROFILE',
                                    style: GoogleFonts.orbitron(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                            ),
                          );
                        }
                      ),
                      
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin ? "NEED ACCESS? CREATE PROFILE" : "ALREADY REGISTERED? LOGIN",
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: textDim,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: GoogleFonts.jetBrainsMono(color: textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10),
        prefixIcon: Icon(icon, size: 18, color: gold),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: gold.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: gold),
          borderRadius: BorderRadius.circular(4),
        ),
        filled: true,
        fillColor: bgPrimary.withOpacity(0.5),
      ),
      validator: (val) => val == null || val.isEmpty ? "Field required" : null,
    );
  }
}
