import 'package:flutter/material.dart';
import 'package:qr_scanner_app/utils/colors.dart';

class IconsWidget2 extends StatefulWidget {
  const IconsWidget2({
    Key? key,
    required this.iconData,
    required this.label,
  }) : super(key: key);

  final IconData iconData;
  final String label;

  @override
  _IconsWidget2State createState() => _IconsWidget2State();
}

class _IconsWidget2State extends State<IconsWidget2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: grey800,
            child: Icon(
              widget.iconData,
              size: 25,
              color: white,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 14, color: white),
            ),
          ),
        ],
      ),
    );
  }
}
