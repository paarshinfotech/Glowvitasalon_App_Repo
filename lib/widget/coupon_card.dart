import 'package:flutter/material.dart';

class CouponPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = 12.0;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 2 - radius)
      ..arcToPoint(
        Offset(size.width, size.height / 2 + radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 2 + radius)
      ..arcToPoint(
        Offset(0, size.height / 2 - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..close();

    /// BORDER
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = 12.0;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 2 - radius)
      ..arcToPoint(
        Offset(size.width, size.height / 2 + radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height / 2 + radius)
      ..arcToPoint(
        Offset(0, size.height / 2 - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class CouponCard extends StatelessWidget {
  final String title;
  final String discount;
  final String validity;
  final String imageUrl;

  const CouponCard({
    super.key,
    required this.title,
    required this.discount,
    required this.validity,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          /// IMAGE + SHAPE
          ClipPath(
            clipper: _CouponClipper(),
            child: Container(
              height: 105,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.45),
                    BlendMode.darken,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        discount,
                        style: const TextStyle(

                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// BOTTOM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        validity,
                        style: const TextStyle( fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// BORDER
          Positioned.fill(
            child: CustomPaint(
              painter: CouponPainter(),
            ),
          ),
        ],
      ),
    );
  }
}
