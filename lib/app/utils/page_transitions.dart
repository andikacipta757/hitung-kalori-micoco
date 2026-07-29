import 'package:flutter/material.dart';

class SmoothPageRoute {
  /// Transisi Slide Up + Fade In (Sangat cocok untuk membuka layar Detail, Scanner, atau Modal)
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final slideTween = Tween<Offset>(
          begin: const Offset(0.0, 0.15), // Geser sedikit dari bawah
          end: Offset.zero,
        ).animate(curveAnimation);

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curveAnimation);

        return FadeTransition(
          opacity: fadeTween,
          child: SlideTransition(
            position: slideTween,
            child: child,
          ),
        );
      },
    );
  }

  /// Transisi Scale + Fade (Cocok untuk Pop-up Paywall Subscription / AI Camera)
  static Route<T> scaleZoom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.backOut, // Efek membal halus (bounce)
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curveAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
