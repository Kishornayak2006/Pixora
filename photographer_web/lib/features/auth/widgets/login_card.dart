import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/services/auth_service.dart';
import 'gradient_button.dart';
import 'social_button.dart';
import '../../../../core/storage/token_storage.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _remember = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await _authService.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Print backend response to verify payload structure
      print("Login Response Payload: ${response.data}");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      if (response.statusCode == 200) {
        // Extract access token from response
        final token = response.data["access_token"] as String;

        // Persist token via TokenStorage
        await TokenStorage().saveToken(token);
        print("Saved Token: $token");

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful"),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.data["detail"]?.toString() ??
                  "Invalid username or password",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.data["detail"]?.toString() ??
                "Unable to connect to server",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final compact = height < 850;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 174, 140, 241),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 28 : 40,
          vertical: compact ? 20 : 32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/logo.png",
                width: compact ? 80 : 100,
              ),

              SizedBox(height: compact ? 10 : 16),

              Text(
                "Photographer Portal",
                style: TextStyle(
                  fontSize: compact ? 24 : 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff181633),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Welcome back! Sign in to manage\nstudios, events and AI galleries.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: compact ? 16 : 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: const Color(0xffF5F6FA),
                  isDense: compact,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xff6C3EF4),
                      width: 2,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Email is required";
                  }
                  return null;
                },
              ),

              SizedBox(height: compact ? 12 : 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xffF5F6FA),
                  isDense: compact,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xff6C3EF4),
                      width: 2,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Password is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Transform.scale(
                    scale: .85,
                    child: Checkbox(
                      value: _remember,
                      activeColor: const Color.fromARGB(255, 72, 241, 86),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _remember = v!;
                        });
                      },
                    ),
                  ),

                  Text(
                    "Remember me",
                    style: TextStyle(fontSize: compact ? 13 : 14),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: compact ? 13 : 14),
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 12 : 16),

              GradientButton(
                text: "Sign In",
                loading: _loading,
                onPressed: _login,
              ),

              SizedBox(height: compact ? 12 : 16),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Continue with",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: compact ? 12 : 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: compact ? 12 : 16),

              SocialButton(
                text: "Continue with Google",
                icon: Icons.g_mobiledata,
                onPressed: () {},
              ),

              SizedBox(height: compact ? 12 : 16),

              GestureDetector(
                onTap: () {
                  // Handle navigation to sign up screen
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: compact ? 13 : 14,
                    ),
                    children: const [
                      TextSpan(
                        text: "Don't have an account? ",
                      ),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: Color.fromARGB(255, 71, 244, 62),
                          fontWeight: FontWeight.bold,
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
}