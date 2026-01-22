import 'package:flutter/material.dart';

import '../theme/walletlly_palette.dart';

class WalletllyBrandBanner extends StatelessWidget {
  const WalletllyBrandBanner({
    super.key,
    this.title = 'Walletlly',
    this.subtitle = 'Personal finance made simple',
    this.compact = false,
    this.leading,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool compact;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = WalletllyPalette.of(context);
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    final double iconSize = compact ? 38 : 42;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.primaryDark, palette.primaryBase],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 22 : 26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140E4D92),
            offset: Offset(0, 10),
            blurRadius: 26,
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: compact ? 10 : 14),
          ],
          Container(
            height: iconSize,
            width: iconSize,
            decoration: BoxDecoration(
              color: palette.primaryLight,
              borderRadius: BorderRadius.circular(iconSize / 2.5),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: palette.primaryBase,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
