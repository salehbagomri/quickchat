import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickchat/data/services/whatsapp_service.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Bottom sheet that opens the device camera to scan a QR code.
///
/// Extracts a phone number from the scanned content and calls [onPhoneDetected].
/// Camera is used locally; no image or scan data is sent anywhere.
class QrScannerSheet extends StatefulWidget {
  final void Function(String phone) onPhoneDetected;

  const QrScannerSheet({required this.onPhoneDetected, super.key});

  /// Convenience launcher — shows the sheet and awaits user action.
  static Future<void> show(
    BuildContext context, {
    required void Function(String phone) onPhoneDetected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => QrScannerSheet(onPhoneDetected: onPhoneDetected),
    );
  }

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  final _controller = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue ?? '';
      final phone = WhatsAppService.extractPhoneNumber(raw);
      if (phone != null) {
        _detected = true;
        Navigator.of(context).pop();
        widget.onPhoneDetected(phone);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final height = MediaQuery.of(context).size.height * 0.55;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.scanQrCode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // Camera view
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scanQrHint,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.outlined(
                tooltip: l10n.flashlight,
                icon: const Icon(Icons.flashlight_on_outlined),
                onPressed: () => _controller.toggleTorch(),
              ),
              IconButton.outlined(
                tooltip: l10n.flipCamera,
                icon: const Icon(Icons.flip_camera_android_outlined),
                onPressed: () => _controller.switchCamera(),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
