import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Converts a YUV420 [CameraImage] to NV21 format.
Uint8List convertYUV420ToNV21(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int ySize = width * height;
  final int uvSize = ySize ~/ 2;
  final Uint8List nv21 = Uint8List(ySize + uvSize);

  // Copy Y plane.
  final Plane yPlane = image.planes[0];
  for (int row = 0; row < height; row++) {
    final int rowStart = row * yPlane.bytesPerRow;
    nv21.setRange(row * width, row * width + width, yPlane.bytes, rowStart);
  }

  // Interleave V and U planes. For NV21, V comes first, then U.
  final Plane uPlane = image.planes[1];
  final Plane vPlane = image.planes[2];
  int uvOffset = ySize;
  for (int row = 0; row < height ~/ 2; row++) {
    final int uRowStart = row * uPlane.bytesPerRow;
    final int vRowStart = row * vPlane.bytesPerRow;
    for (int col = 0; col < width ~/ 2; col++) {
      nv21[uvOffset++] = vPlane.bytes[vRowStart + col];
      nv21[uvOffset++] = uPlane.bytes[uRowStart + col];
    }
  }
  return nv21;
}

/// Converts a [CameraImage] (YUV420) to an [InputImage] using NV21 conversion.
/// [sensorOrientation] is the sensor orientation (in degrees) from the camera.
InputImage convertCameraImageToInputImage(
  CameraImage image,
  int sensorOrientation,
) {
  final Uint8List nv21Bytes = convertYUV420ToNV21(image);
  InputImageRotation rotation;
  if (sensorOrientation == 90) {
    rotation = InputImageRotation.rotation90deg;
  } else if (sensorOrientation == 180) {
    rotation = InputImageRotation.rotation180deg;
  } else if (sensorOrientation == 270) {
    rotation = InputImageRotation.rotation270deg;
  } else {
    rotation = InputImageRotation.rotation0deg;
  }
  final InputImageMetadata metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    format: InputImageFormat.nv21,
    bytesPerRow: image.width,
  );
  return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
}
