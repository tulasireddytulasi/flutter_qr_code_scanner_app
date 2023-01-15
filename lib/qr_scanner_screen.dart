import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner_app/utils/colors.dart';
import 'package:qr_scanner_app/widgets/icons_widget.dart';
import 'package:qr_scanner_app/widgets/icons_widget_2.dart';
import 'package:qr_scanner_app/widgets/qr_code_data_view_widget.dart';
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
  bool _isBottomSheetOpened = false;

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
    debugPrint("Camera Paused");
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
    /// For this example we check how width or tall the device
    /// is and change the scanArea and overlay accordingly.
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
        if (result != null && _isBottomSheetOpened == false) {
          _isBottomSheetOpened = true;
          _showBottomSheet(
            barCodeType: describeEnum(result!.format),
            qrCodeData: result!.code!,
          );
          pauseCamera();
        }
      });
    });
  }

  Future<void> openUrl({required String data}) async {
    final Uri url = Uri.parse(data);
    await launchUrl(url);
  }

  void _closeBottomSheet() {
    Navigator.pop(context);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _showBottomSheet({
    required String barCodeType,
    required String qrCodeData,
  }) {
    showModalBottomSheet(
        context: context,
        backgroundColor: white,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        elevation: 1,
        barrierColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.4,
            maxChildSize: 0.9,
            minChildSize: 0.32,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  decoration: const BoxDecoration(
                    color: grey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        QRCodeDataViewWidget(
                          barCodeType: barCodeType,
                          qrCodeData: qrCodeData,
                        ),
                        const SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            labels.length,
                            (index) {
                              return IconsWidget2(
                                label: labels[index],
                                iconData: icons[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).whenComplete(() {
      debugPrint("Bottom Sheet closed");
      _isBottomSheetOpened = false;
      resumeCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
