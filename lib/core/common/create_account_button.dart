import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';

import '../../features/app/app_text_field.dart';

class CreateAccountButton extends ConsumerStatefulWidget {
  final bool isFromLogin;

  CreateAccountButton({Key? key, this.isFromLogin = true}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateAccountButtonState();
}

class _CreateAccountButtonState extends ConsumerState<CreateAccountButton> {
  void createAccountWithGoogle(BuildContext context, WidgetRef ref) async {

    final ValueNotifier<String?> showSelectedDate = ValueNotifier(null);
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
                    AppTextField(
                      hintText: 'First Name',
                      controller: firstNameController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    AppTextField(
                      hintText: 'Last Name',
                      controller: lastNameController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ValueListenableBuilder<String?>(
                                      valueListenable: showSelectedDate,
                                      builder: (context, date, _) {
                                        return Text(
                                          '${date == null ? 'select birth date' : date}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        );
                                      })
                                ],
                              ),
                            )),
                        onTap: () async {
                          final datePick = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(),
                              firstDate: new DateTime(1900),
                              lastDate: new DateTime(2100));
                          if (datePick != null) {
                            if(datePick.year > 2014){
                              notifyDialog(context, 'Year of Birth can\'t be smaller than 2014!');
                              return ;
                            }
                            birthDate = datePick;
                            showSelectedDate.value =
                            "${birthDate!.month}/${birthDate!.day}/${birthDate!.year}";
                          }
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                        child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                                child: Text(
                                  'Done',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                                ))),
                        onTap: () {
                          if (!(firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              birthDate == null)) {
                            Navigator.pop(context);
                            ref
                                .read(authControllerProvider.notifier)
                                .createAccountWithGoogle(context, widget.isFromLogin,
                                lastName: lastNameController.text,
                                firstName: firstNameController.text,
                                birthDate: showSelectedDate.value);
                          }else{
                            notifyDialog(context, 'please fill all information');
                          }
                        })
                  ],
                ),
              ),
            );
          });
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
          onPressed: () => createAccountWithGoogle(context, ref),
          icon: SizedBox.shrink(),
          label: const Text(
            'Create Account',
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
