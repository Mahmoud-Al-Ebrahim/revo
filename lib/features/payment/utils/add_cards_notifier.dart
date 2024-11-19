import 'package:flutter/material.dart';

class AddCardNotifier extends ChangeNotifier {
  bool _enterCardNumber = false;
  bool _enterExpireDate = false;
  bool _enterCvv = false;
  bool _enterCardHolder = false;
  bool _enterPaymentCode = false;

  set enterCardNumber(bool value) {
    _enterCardNumber = value;
    notifyListeners();
  }

  set enterPaymentCode(bool value) {
    _enterPaymentCode = value;
    notifyListeners();
  }

  set enterExpireDate(bool value) {
    _enterExpireDate = value;
    notifyListeners();
  }

  set enterCvv(bool value) {
    _enterCvv = value;
    notifyListeners();
  }

  set enterCardHolder(bool value) {
    _enterCardHolder = value;
    notifyListeners();
  }
  bool get code => _enterPaymentCode;
  bool get fillAllInfo => (_enterCardNumber &&
          _enterExpireDate &&
          _enterCvv &&
          _enterCardHolder);

}
