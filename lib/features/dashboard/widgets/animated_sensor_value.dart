import 'package:flutter/material.dart';

class AnimatedSensorValue extends StatefulWidget {
  final double? value;
  final String unit;
  final Color color;
  final bool isStale;

  const AnimatedSensorValue({
    super.key,
    required this.value,
    required this.unit,
    required this.color,
    this.isStale = false,
  });

  @override
  State<AnimatedSensorValue> createState() => _AnimatedSensorValueState();
}

class _AnimatedSensorValueState extends State<AnimatedSensorValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  double? _displayedValue;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _displayedValue = widget.value;
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedSensorValue old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.forward(from: 0.3);
      _displayedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedValue == null) {
      return Text(
        '—',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: widget.color.withOpacity(0.4),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _displayedValue!.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: widget.isStale
                  ? widget.color.withOpacity(0.4)
                  : widget.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              widget.unit,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: widget.isStale
                    ? widget.color.withOpacity(0.4)
                    : widget.color.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
