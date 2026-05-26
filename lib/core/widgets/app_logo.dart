import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 44,
    this.showText = true,
    this.subtitle,
    this.centered = false,
    this.textColor = const Color(0xFF0B1F33),
    this.subtitleColor,
  });

  static const assetPath = 'assets/logo.png';

  final double size;
  final bool showText;
  final String? subtitle;
  final bool centered;
  final Color textColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showText) {
      return Semantics(label: 'SnapBuy logo', child: logo);
    }

    final titleSize = size >= 44 ? 30.0 : 24.0;
    final subtitleStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: subtitleColor ?? textColor.withValues(alpha: 0.78),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );

    return Row(
      mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Semantics(label: 'SnapBuy logo', child: logo),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: centered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SnapBuy',
              style: TextStyle(
                color: textColor,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
            if (subtitle != null) Text(subtitle!, style: subtitleStyle),
          ],
        ),
      ],
    );
  }
}
