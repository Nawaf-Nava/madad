import 'package:flutter/material.dart';

import '../theme/madad_theme.dart';

Route<T> madadPageRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 190),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .025),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

class MadadPageHeader extends StatelessWidget {
  const MadadPageHeader({
    required this.title,
    required this.subtitle,
    this.icon = Icons.account_balance_wallet_outlined,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: MadadSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MadadColors.orangeSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MadadColors.border),
              ),
              child: Icon(icon, color: MadadColors.orange),
            ),
            const SizedBox(width: MadadSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: MadadSpace.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
}

class MadadSectionTitle extends StatelessWidget {
  const MadadSectionTitle(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: MadadSpace.sm),
        child: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class MadadNotice extends StatelessWidget {
  const MadadNotice({
    required this.message,
    this.icon = Icons.info_outline_rounded,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(MadadSpace.md),
        decoration: BoxDecoration(
          color: MadadColors.orangeSurface,
          borderRadius: BorderRadius.circular(MadadRadius.field),
          border: Border.all(color: MadadColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: MadadColors.orange, size: 20),
            const SizedBox(width: MadadSpace.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MadadColors.textPrimary,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      );
}

class MadadEmptyState extends StatelessWidget {
  const MadadEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight.isFinite && constraints.maxHeight < 220;
          final iconSize = compact ? 44.0 : 76.0;
          final gap = compact ? 6.0 : MadadSpace.md;
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 18 : 28,
                vertical: compact ? 8 : 36,
              ),
              child: SingleChildScrollView(
                physics: compact
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: MadadColors.orangeSurface,
                        borderRadius: BorderRadius.circular(compact ? 16 : 26),
                        border: Border.all(color: MadadColors.border),
                      ),
                      child: Icon(
                        icon,
                        color: MadadColors.orange,
                        size: compact ? 24 : 34,
                      ),
                    ),
                    SizedBox(height: gap),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: compact ? 2 : MadadSpace.xs),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: compact ? 1.25 : 1.45,
                          ),
                    ),
                    if (action != null) ...[
                      SizedBox(height: gap),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class MadadServiceTile extends StatelessWidget {
  const MadadServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: MadadSpace.md,
            vertical: MadadSpace.xs,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MadadColors.orangeSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: MadadColors.orange),
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle:
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: MadadColors.textSecondary,
          ),
          onTap: onTap,
        ),
      );
}
