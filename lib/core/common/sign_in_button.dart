import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';

import '../../features/app/app_text_field.dart';

class SignInButton extends ConsumerStatefulWidget {

  SignInButton({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<SignInButton> {
  void signInWithGoogle(BuildContext context, WidgetRef ref) async {
      ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(context);
  }

  String? birthDateInString;
  DateTime? birthDate;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(context, ref),
          icon: Image.asset(
            Constants.googlePath,
            width: 35,
          ),
          label: const Text(
            'Login with Google',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Pallete.greyColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        )
    );
  }
}
