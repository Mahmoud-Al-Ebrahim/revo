import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/helper_functions.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../app/app_bottom_sheet.dart';
import '../../auth/controlller/auth_controller.dart';
import '../../payment/add_card_content.dart';
import '../../user_profile/controller/user_profile_controller.dart';

class BuyAwardsScreen extends ConsumerWidget {
   BuyAwardsScreen({super.key});

  List<String> awards = [
    'awesomeAns',
    'gold',
    'platinum',
    'helpful',
    'plusone',
    'rocket',
    'thankyou',
    'til',
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
        appBar: AppBar(
            title: const Text('Get More Awards'),
            leading: InkWell(
                onTap: () => Routemaster.of(context).pop(),
                child: const Icon(Icons.arrow_back))),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 0.8),
            itemCount: awards.length,
            itemBuilder: (BuildContext context, int index) {
              final award = awards[index];
              String price = (Random().nextDouble() * 50).toStringAsFixed(2);
              return GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) {
                        return IntrinsicHeight(
                          child: AlertDialog(
                            backgroundColor: Colors.white,
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                    child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                            child: Text(
                                          'By Wallet',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ))),
                                    onTap: () {
                                      if (double.parse(price) >
                                          user.walletBalance) {
                                        notifyDialog(context,
                                            'You don\'t have enough money in your wallet');
                                        return;
                                      }
                                      ref
                                          .read(userProfileControllerProvider
                                              .notifier)
                                          .updateUserWallet(
                                              double.parse(price));
                                      toastMessage('award Bought Successfully',
                                          isGoodMessage: true);
                                    }),
                                SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                    child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                            child: Text(
                                          'By Cards',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ))),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      AppBottomSheet.show(
                                          context: context,
                                          child: const AddCardContent());
                                    }),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset(Constants.awards[award]!),
                      Text('$price \$')
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
