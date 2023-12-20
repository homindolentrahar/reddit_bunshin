import 'package:flutter/material.dart';
import 'package:reddit_bunshin/core/ui/themes.dart';
import 'package:reddit_bunshin/gen/assets.gen.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        Assets.images.google.path,
        width: 48,
        height: 48,
      ),
      label: const Text(
        "Continue with Google",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.greyColor,
        minimumSize: Size(MediaQuery.of(context).size.width, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
