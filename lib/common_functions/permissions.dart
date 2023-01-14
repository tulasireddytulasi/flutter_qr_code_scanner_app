import 'package:permission_handler/permission_handler.dart';

class MyPermissions {
  Future<PermissionStatus> _getCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      return result;
    } else {
      return status;
    }
  }

  Future<void> getPer() async {
    PermissionStatus status = await _getCameraPermission();
    if (status.isGranted) {
      print("Permission Granted");
    } else {
      print("Permission Not Granted");
    }
  }
}
