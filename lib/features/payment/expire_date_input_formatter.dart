import 'package:flutter/services.dart';

class CardExpireDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if(newText.length==1){
      if (int.parse(newText[0]) > 1){
        return oldValue;
      }
    }
    if(newText.length==2) {
      if ((int.parse(newText[0]) == 0) && (int.parse(newText[1]) > 9 || int.parse(newText[1])==0) ||
          ((int.parse(newText[0]) == 1) && int.parse(newText[1]) > 2)) {
        return oldValue;
      }
    }
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}