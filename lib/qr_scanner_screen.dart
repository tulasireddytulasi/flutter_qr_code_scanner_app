import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner_app/utils/colors.dart';
import 'package:qr_scanner_app/widgets/icons_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  /// In order to get hot reload to work we need to pause the camera if the platform
  /// is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  final List<IconData> icons = [
    Icons.flash_on,
    Icons.flip_camera_ios_outlined,
    Icons.pause,
    Icons.start
  ];
  final List<String> labels = ["Flash: On", "Flip Camera", "Pause", "Resume"];

  @override
  void initState() {
    super.initState();
  }

  myFunction({required int index}) {
    switch (index) {
      case 0:
        flashLight();
        break;
      case 1:
        flipCamera();
        break;
      case 2:
        pauseCamera();
        break;
      case 3:
        resumeCamera();
        break;
    }
  }

  void flashLight() async {
    await controller?.toggleFlash();
    final flashStatus = await controller?.getFlashStatus();
    print("getFlashStatus: $flashStatus");
    setState(() {});
  }

  void flipCamera() async {
    await controller?.flipCamera();
    final cameraStatus = await controller?.getCameraInfo();
    print("getCameraInfo: ${describeEnum(cameraStatus!).trim()}");
    setState(() {});
  }

  void pauseCamera() async {
    await controller?.pauseCamera();
  }

  void resumeCamera() async {
    await controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: _buildQrView(context)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (result == null)
                const Text(
                  'Scan a code',
                  style: const TextStyle(fontSize: 18, color: black),
                ),
              if (result != null) const SizedBox(height: 10),
              if (result != null)
                Text(
                  "Barcode Type: ${result != null ? describeEnum(result!.format) : "No Data"}",
                  style: const TextStyle(fontSize: 18, color: black),
                ),
              if (result != null) const SizedBox(height: 10),
              if (result != null)
                Text(
                  "Data: ${result != null ? result!.code : "No Data"}",
                  style: const TextStyle(fontSize: 18, color: black),
                  maxLines: 6,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),
              Container(
                color: grey900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    labels.length,
                    (index) => InkWell(
                      onTap: () => myFunction(index: index),
                      child: IconsWidget(
                          label: labels[index], iconData: icons[index]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    /// For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    /// To ensure the Scanner view is properly sizes after rotation
    /// we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          // openUrl(data: result!.code!);
        }
      });
    });
  }

  Future<void> openUrl({required String data}) async {
    final Uri _url = Uri.parse(data);
    await launchUrl(_url);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
