import 'package:flutter/material.dart';
import 'package:qr_scanner_app/utils/colors.dart';

class QRCodeDataViewWidget extends StatelessWidget {
  const QRCodeDataViewWidget({
    Key? key,
    required this.barCodeType,
    required this.qrCodeData,
  }) : super(key: key);
  final String barCodeType;
  final String qrCodeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Barcode Type: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: barCodeType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "QR Data: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: qrCodeData,
                  style: const TextStyle(
                    fontSize: 14,
                    color: black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
