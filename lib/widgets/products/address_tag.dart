import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget {
  final String addressText;

  AddressTag(this.addressText);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(addressText),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
    );
  }
}
