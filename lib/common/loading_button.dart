import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

typedef AsyncCallback = Future<void> Function();

class LoadingButton extends StatelessWidget {
  final String text;

  final AsyncCallback? onPressed;
  final bool isLoading;
  final Color? buttonColor;
  final Color? textColor;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.buttonColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? Colors.deepPurple,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/waiting.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
