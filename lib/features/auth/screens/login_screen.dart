import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/sign_in_button.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/responsive/responsive.dart';

import '../../../core/common/create_account_button.dart';
import '../../../theme/pallete.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Builder(
        builder: (context) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
              ),
              body: isLoading
                  ? const Loader()
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Dive into anything',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        Constants.loginEmotePath,
                        height: 350,
                      ),
                    ),
                    Responsive(child: SignInButton()),
                    Responsive(child: CreateAccountButton()),
                    Responsive(child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: ElevatedButton.icon(
                          onPressed: () => signInAsGuest(ref, context),
                          icon: SizedBox.shrink(),
                          label: const Text(
                            'Continue as Guest',
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
                    )),
                  ],
                ),)
          );
        }
    );
  }
}
