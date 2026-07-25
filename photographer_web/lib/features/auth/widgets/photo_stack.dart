import 'package:flutter/material.dart';

class PhotoStack extends StatelessWidget {
  const PhotoStack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 470,
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -.08,
              child: _photoCard(
                "assets/images/hero1.jpg",
              ),
            ),
          ),
          Positioned(
            left: 170,
            top: 10,
            child: Transform.rotate(
              angle: .08,
              child: _photoCard(
                "assets/images/hero2.jpg",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(String image) {
    return Container(
      width: 240,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            color: Colors.black26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}