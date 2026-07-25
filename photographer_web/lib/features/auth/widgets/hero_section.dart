import 'dart:ui';

import 'package:flutter/material.dart';

import 'feature_tile.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff4F46E5),
            Color(0xff6D28D9),
            Color(0xff8B5CF6),
            Color(0xffA855F7),
          ],
        ),
      ),
      child: Stack(
        children: [
          const _BlurCircle(
            top: -170,
            left: -140,
            size: 420,
            color: Color(0x30FFFFFF),
          ),

          const _BlurCircle(
            top: 120,
            right: -80,
            size: 250,
            color: Color(0x20FFFFFF),
          ),

          const _BlurCircle(
            bottom: -140,
            right: -120,
            size: 380,
            color: Color(0x25FFFFFF),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 56,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        width: 154,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        "Pixora",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: .6,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Every Moments.\nMake it instantly theirs.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.08,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 460,
                    child: Text(
                      "Pixora helps photographers upload event galleries once, "
                      "then automatically lets every guest discover their own "
                      "photos instantly using powerful AI face recognition.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 17,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: const [
                      FeatureTile(
                        icon: Icons.cloud_upload_rounded,
                        title: "Lightning Upload",
                      ),
                      FeatureTile(
                        icon: Icons.photo_library_rounded,
                        title: "Unlimited Galleries",
                      ),
                      FeatureTile(
                        icon: Icons.face_retouching_natural_rounded,
                        title: "AI Face Recognition",
                      ),
                      FeatureTile(
                        icon: Icons.security_rounded,
                        title: "Privacy First",
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  const _BlurCircle({
    super.key,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 90,
          sigmaY: 90,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}