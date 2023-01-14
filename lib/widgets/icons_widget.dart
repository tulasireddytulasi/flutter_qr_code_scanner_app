import 'package:flutter/material.dart';
import 'package:qr_scanner_app/utils/colors.dart';

class IconsWidget extends StatefulWidget {
  const IconsWidget({Key? key, required this.iconData, required this.label})
      : super(key: key);
  final IconData iconData;
  final String label;

  @override
  _IconsWidgetState createState() => _IconsWidgetState();
}

class _IconsWidgetState extends State<IconsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
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
            margin: const EdgeInsets.only(top: 10, bottom: 10),
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
