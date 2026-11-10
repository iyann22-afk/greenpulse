import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

/// Wraps the application inside a realistic mobile smartphone frame
/// when opened on wide desktop or web screens for presentation and review.
class PhoneFrameWrapper extends StatefulWidget {
  final Widget child;

  const PhoneFrameWrapper({super.key, required this.child});

  @override
  State<PhoneFrameWrapper> createState() => _PhoneFrameWrapperState();
}

class _PhoneFrameWrapperState extends State<PhoneFrameWrapper> {
  bool _enablePhoneFrame = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If already on a narrow mobile viewport (< 520px) or on real mobile platform without web
        final isNarrow = constraints.maxWidth < 520;
        if (isNarrow || !_enablePhoneFrame) {
          return Stack(
            children: [
              widget.child,
              if (!isNarrow)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildFloatingToggle(
                    icon: Icons.smartphone_rounded,
                    label: 'Show Phone Frame',
                    onTap: () => setState(() => _enablePhoneFrame = true),
                  ),
                ),
            ],
          );
        }

        // Desktop / wide screen presentation with sleek phone mockup
        return Scaffold(
          backgroundColor: const Color(0xFF0F1E16),
          body: Stack(
            children: [
              // Stylized ambient background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 1.2,
                      colors: [
                        Color(0xFF1B3D2B),
                        Color(0xFF0E2318),
                        Color(0xFF08140E),
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle background grid & branding
              Positioned.fill(
                child: CustomPaint(
                  painter: _DesktopBackgroundPainter(),
                ),
              ),

              // Desktop Header Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pulseGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.pulseGreen.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppColors.freshLime,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'GREENPULSE',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Smart Agriculture IoT · Mobile Simulator',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildFloatingToggle(
                          icon: Icons.fullscreen_rounded,
                          label: 'Full Window',
                          onTap: () =>
                              setState(() => _enablePhoneFrame = false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Centered Phone Frame
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _buildSmartphoneMockup(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingToggle({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.freshLime, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartphoneMockup(BuildContext context) {
    const double phoneWidth = 390.0;
    const double phoneHeight = 844.0;
    const double bezelRadius = 48.0;
    const double screenRadius = 40.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Side Hardware Buttons
        // Volume buttons (Left)
        Positioned(
          left: -4,
          top: 150,
          child: _buildSideButton(width: 4, height: 48),
        ),
        Positioned(
          left: -4,
          top: 210,
          child: _buildSideButton(width: 4, height: 48),
        ),
        // Power button (Right)
        Positioned(
          right: -4,
          top: 180,
          child: _buildSideButton(width: 4, height: 72),
        ),

        // Outer Chassis / Bezel
        Container(
          width: phoneWidth + 24,
          height: phoneHeight + 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2320),
            borderRadius: BorderRadius.circular(bezelRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF38433C),
                Color(0xFF1E2320),
                Color(0xFF131714),
                Color(0xFF2C352F),
              ],
            ),
            boxShadow: [
              // Deep ambient drop shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.65),
                blurRadius: 50,
                spreadRadius: 8,
                offset: const Offset(0, 20),
              ),
              // Subtle green edge glow
              BoxShadow(
                color: AppColors.pulseGreen.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4A574E),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenRadius),
            child: Stack(
              children: [
                // Inner Screen Content
                SizedBox(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: const Size(phoneWidth, phoneHeight),
                      padding: const EdgeInsets.only(top: 44, bottom: 34),
                      viewPadding:
                          const EdgeInsets.only(top: 44, bottom: 34),
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: widget.child,
                  ),
                ),

                // Top Dynamic Island / Camera Notch
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Camera lens reflection
                          Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111C24),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF223544),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF254B6E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sensor dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0C1410),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Home Bar Indicator
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 135,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF38433C),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _DesktopBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DesktopBackgroundPainter old) => false;
}
