import 'package:accollect/core/app_router.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  BarcodeScannerScreenState createState() => BarcodeScannerScreenState();
}

class BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _mobileScannerController =
      MobileScannerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _disableScreenSleep();
  }

  Future<void> _disableScreenSleep() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _mobileScannerController.stop();
    _mobileScannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _returnResult(String? barcodeValue) {
    if (!mounted || barcodeValue == null || barcodeValue.isEmpty) return;
    _mobileScannerController.stop();
    context.pop(Result(content: barcodeValue, status: Status.ok));
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseableAppBar(title: 'Scan Barcode'),
      body: Stack(
        children: [
          MobileScanner(
            controller: _mobileScannerController,
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              final code = barcode.rawValue;
              if (code != null) {
                HapticFeedback.mediumImpact();
                _showToast("Scanned: $code");
                _returnResult(code);
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Text('Camera error: ${error.errorCode}'),
              );
            },
            fit: BoxFit.cover,
          ),
          _buildSquareOverlay(),
          _buildFlashToggle(),
          _buildInstructionText(),
          _buildCancelButton(),
        ],
      ),
    );
  }

  Widget _buildSquareOverlay() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(16),
              color: Colors.black
                  .withValues(alpha: 0.3), // Semi-transparent background
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 220),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Positioned(
                top: value,
                left: 20,
                right: 20,
                child: Container(
                  height: 3,
                  color: Colors.redAccent,
                ),
              );
            },
            onEnd: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          onEnd: () => setState(() {}),
          child: const Text(
            "Align the barcode inside the frame",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
      ),
    );
  }

  bool _isFlashOn = false; // Track torch state manually

  Widget _buildFlashToggle() {
    return Positioned(
      bottom: 100,
      child: Center(
        child: FloatingActionButton(
          backgroundColor: Colors.black54,
          child: Icon(
            _isFlashOn ? Icons.flash_on : Icons.flash_off,
            color: Colors.yellowAccent,
          ),
          onPressed: () async {
            await _mobileScannerController.toggleTorch();
            HapticFeedback.mediumImpact();
            setState(() {
              _isFlashOn = !_isFlashOn;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          _mobileScannerController.stop();
          context.pop(Result(status: Status.fail));
        },
        child: const Text(
          "Cancel",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
