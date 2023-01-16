import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner_app/utils/colors.dart';
import 'package:qr_scanner_app/widgets/icons_widget.dart';
import 'package:qr_scanner_app/widgets/icons_widget_2.dart';
import 'package:qr_scanner_app/widgets/qr_code_data_view_widget.dart';
import 'package:share_plus/share_plus.dart';
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
  bool? _flashStatus = false;
  bool _isCameraPaused = false;

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
  String flashStatus = "";
  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    flashStatus = _flashStatus != null && _flashStatus! ? "On" : "Off";
    setState(() {});
  }

  final List<IconData> icons2 = [
    Icons.open_in_new,
    Icons.copy,
    Icons.share,
    Icons.close,
  ];
  final List<String> labels2 = ["Open Link", "Copy", "Share", "Close"];

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

  bottomSheetMethods({required int index}) {
    switch (index) {
      case 0:
        openUrl(data: result!.code!);
        break;
      case 1:
        copyText();
        break;
      case 2:
        shareQRData();
        break;
      case 3:
        _closeBottomSheet();
        break;
    }
  }

  void copyText() => Clipboard.setData(ClipboardData(text: result!.code));

  void shareQRData() {
    Share.share(result?.code ?? "");
  }

  void flashLight() async {
    await controller?.toggleFlash();
    _flashStatus = await controller?.getFlashStatus();
    print("getFlashStatus: $_flashStatus");
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
    _isCameraPaused = true;
    debugPrint("Camera Paused");
    setState(() {});
  }

  void resumeCamera() async {
    await controller?.resumeCamera();
    setState(() {});
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
                  children: [
                    InkWell(
                      onTap: () => flashLight(),
                      child: IconsWidget(
                        label:
                            "Flash: ${_flashStatus != null && _flashStatus! ? "On" : "Off"}",
                        iconData: Icons.flash_on,
                        iconData2: Icons.flash_off_outlined,
                        isClicked: _flashStatus ?? false,
                      ),
                    ),
                    InkWell(
                      onTap: () => flipCamera(),
                      child: const IconsWidget(
                        label: "Flip Camera",
                        iconData: Icons.flip_camera_ios_outlined,
                        iconData2: Icons.flip_camera_ios_outlined,
                        isClicked: false,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_isCameraPaused) {
                          _isCameraPaused = false;
                          resumeCamera();
                        } else {
                          pauseCamera();
                        }
                      },
                      child: IconsWidget(
                        label: _isCameraPaused ? "Paused" : "Pause",
                        iconData: Icons.not_started_rounded,
                        iconData2: Icons.pause,
                        isClicked: _isCameraPaused,
                      ),
                    ),
                  ],
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
    if (data.contains("http")) {
      final Uri url = Uri.parse(data);
      await launchUrl(url);
    } else {
      // Fluttertoast.showToast(
      //     msg: "This is Center Short Toast",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
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
            initialChildSize: 0.25,
            maxChildSize: 0.9,
            minChildSize: 0.2,
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
                            labels2.length,
                            (index) {
                              return InkWell(
                                onTap: () => bottomSheetMethods(index: index),
                                child: IconsWidget2(
                                  label: labels2[index],
                                  iconData: icons2[index],
                                ),
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
      _isCameraPaused = false;
      resumeCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
