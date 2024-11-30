import 'package:flutter/material.dart';

class NativeInfoPopup extends StatefulWidget {
  final Widget child; // Widget pemicu, misalnya ikon
  final Widget popupContent; // Konten popup
  final Offset contentOffset; // Jarak popup dari pemicu
  final Color arrowColor; // Warna panah popup
  final double arrowSize; // Ukuran panah

  const NativeInfoPopup({
    super.key,
    required this.child,
    required this.popupContent,
    this.contentOffset = const Offset(0, 10),
    this.arrowColor = Colors.black,
    this.arrowSize = 10.0,
  });

  @override
  State<NativeInfoPopup> createState() => _NativeInfoPopupState();
}

class _NativeInfoPopupState extends State<NativeInfoPopup> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showPopup() {
    if (_overlayEntry != null) return; // Jika popup sudah muncul, abaikan
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Hitung posisi popup agar tetap dalam layar
        final popupWidth = size.width * 2; // Estimasi lebar konten popup
        final adjustedLeft = offset.dx + widget.contentOffset.dx;

        final leftPosition = adjustedLeft + popupWidth > screenWidth
            ? screenWidth - popupWidth - 16 // Offset agar tidak keluar layar
            : adjustedLeft;

        return Stack(
          children: [
            // Area untuk menutup popup saat di-tap
            GestureDetector(
              onTap: _hidePopup,
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            // Posisi popup
            Positioned(
              left: leftPosition,
              top: offset.dy + size.height + widget.contentOffset.dy,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panah di tengah
                      Align(
                        alignment: Alignment.center,
                        child: CustomPaint(
                          painter: ArrowPainter(
                            color: widget.arrowColor,
                            size: widget.arrowSize,
                          ),
                          size: Size(widget.arrowSize * 2, widget.arrowSize),
                        ),
                      ),
                      // Konten Popup
                      widget.popupContent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_overlayEntry == null) {
            _showPopup();
          } else {
            _hidePopup();
          }
        },
        child: widget.child,
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final double size;

  ArrowPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
