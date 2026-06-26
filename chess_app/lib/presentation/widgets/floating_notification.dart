import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Affiche une notification flottante en haut de l'écran,
// comme une vraie notification téléphone — apparaît puis disparaît seule
void showFloatingNotification(
  BuildContext context, {
  required String message,
  required IconData icon,
  Color color = AppColors.error,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _FloatingNotificationWidget(
      message: message,
      icon: icon,
      color: color,
      onDismiss: () => entry.remove(),
      duration: duration,
    ),
  );

  overlay.insert(entry);
}

class _FloatingNotificationWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;
  final Duration duration;

  const _FloatingNotificationWidget({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_FloatingNotificationWidget> createState() =>
      _FloatingNotificationWidgetState();
}

class _FloatingNotificationWidgetState
    extends State<_FloatingNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Glisse depuis le haut de l'écran
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Disparaît automatiquement après la durée demandée
    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              // Toucher la notification la fait disparaître plus vite
              onTap: _dismiss,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border(
                    left: BorderSide(color: widget.color, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.color, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}