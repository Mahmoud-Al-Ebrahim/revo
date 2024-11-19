import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/features/payment/utils/add_cards_notifier.dart';
import 'package:reddit/features/payment/utils/card_type.dart';
import 'package:reddit/features/payment/utils/card_utilis.dart';
import '../app/app_text_field.dart';
import 'card_number_input_formatter.dart';
import 'expire_date_input_formatter.dart';

class AddCardContent extends StatefulWidget {
  const AddCardContent({Key? key}) : super(key: key);

  @override
  State<AddCardContent> createState() => _AddCardContentState();
}

class _AddCardContentState extends State<AddCardContent> {
  late final ValueNotifier<CardType> cardType;
  late final ValueNotifier<bool> saveValue;
  late final AddCardNotifier addCardNotifier;
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  GlobalKey<FormState> key = GlobalKey<FormState>();

  void getCardTypeFromNumber() {
    if (controllers[0].text.length < 7) {
      String cardNumber = CardUtils.getCleanedNumber(controllers[0].text);
      CardType type = CardUtils.getCardTypeFrmNumber(cardNumber);
      if (type != cardType.value) {
        cardType.value = type;
      }
    }
  }

  @override
  void didChangeDependencies() {
    controllers[0].addListener(() {
      getCardTypeFromNumber();
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    cardType = ValueNotifier(CardType.Invalid);
    saveValue = ValueNotifier(false);
    addCardNotifier = AddCardNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, top: 30),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                    Text('Add Card',
                        style: TextStyle(
                            fontSize: 20, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                  key: key,
                  child: Column(
                    children: [
                      ValueListenableBuilder<CardType>(
                          valueListenable: cardType,
                          builder: (context, cardType, _) {
                            return AppTextField(
                              hintText: 'Card Number',
                              controller: controllers[0],
                              textDirection: TextDirection.ltr,
                              textInputType: TextInputType.number,
                              onChange: (cardNumber) => addCardNotifier
                                  .enterCardNumber = cardNumber.isNotEmpty,
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(19),
                                CardNumberInputFormatter(),
                              ],
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: CardUtils.getCardIcon(cardType),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: SvgPicture.asset('assets/card/card.svg',
                                    color: Colors.deepOrange),
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: AppTextField(
                            hintText: 'MM/YY',
                            textInputType: TextInputType.number,
                            onChange: (expireDate) => addCardNotifier
                                .enterExpireDate = expireDate.isNotEmpty,
                            controller: controllers[1],
                            maxLines: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              CardExpireDateInputFormatter()
                            ],
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(15),
                              child: SvgPicture.asset(
                                  'assets/card/calender.svg',
                                  color: Colors.deepOrange),
                            ),
                          )),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: AppTextField(
                            textInputType: TextInputType.number,
                            controller: controllers[2],
                            hintText: 'cvc/cvv',
                            onChange: (cvv) =>
                                addCardNotifier.enterCvv = cvv.isNotEmpty,
                            maxLines: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(15),
                              child: SvgPicture.asset('assets/card/Cvv.svg',
                                  color: Colors.deepOrange),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      AppTextField(
                        textInputType: TextInputType.text,
                        hintText: 'Card Holder',
                        controller: controllers[3],
                        onChange: (cardHolder) => addCardNotifier
                            .enterCardHolder = cardHolder.isNotEmpty,
                        maxLines: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp(r'[a-z A-Z]'),
                              allow: true)
                        ],
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SvgPicture.asset(
                            'assets/card/person.svg',
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: AnimatedBuilder(
                    animation: addCardNotifier,
                    builder: (context, child) {
                      return GestureDetector(
                          onTap: () {
                            if (!addCardNotifier.fillAllInfo) {
                              toastMessage('Please Fill All Information');
                              return;
                            }
                            if (controllers[0].text.replaceAll(' ', '') ==
                                    '474200000000' &&
                                controllers[1].text == '01/01' &&
                                controllers[2].text == '000') {
                              toastMessage('Card Info Approved , award bought Successfully' , isGoodMessage: true);
                              Navigator.pop(context);
                            }else{
                              toastMessage('Please Enter a Valid Card');
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: size.width * 0.1,
                                right: size.width * 0.1),
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(15),
                                  left: Radius.circular(15),
                                )),
                            width: size.width,
                            child: Center(
                              child: Text(
                                'Continue',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ));
                    })),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
