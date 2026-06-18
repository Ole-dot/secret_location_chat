import 'package:flutter/material.dart';

/// System bottom inset (home indicator / 3-button navigation bar).
double systemBottomInset(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom;

/// Default padding for scrollable scaffold bodies (use inside [SafeArea]).
const EdgeInsets kScreenContentPadding = EdgeInsets.all(20);

/// Bottom padding for modal sheets: keyboard when open, otherwise nav bar + [spacing].
double sheetBottomPadding(
  BuildContext context, {
  double spacing = 16,
}) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  if (keyboard > 0) return keyboard + spacing;
  return systemBottomInset(context) + spacing;
}

/// Adds only the system bottom inset on top of [extra] (backgrounds can stay edge-to-edge).
class SafeBottom extends StatelessWidget {
  const SafeBottom({
    super.key,
    required this.child,
    this.extra = 16,
    this.minimum = 0,
  });

  final Widget child;
  final double extra;
  final double minimum;

  @override
  Widget build(BuildContext context) {
    final inset = systemBottomInset(context);
    final bottom = (inset > minimum ? inset : minimum) + extra;
    if (bottom <= 0) return child;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}

/// Standard scaffold body below an [AppBar]: respects bottom system UI.
class ScreenScrollBody extends StatelessWidget {
  const ScreenScrollBody({
    super.key,
    required this.child,
    this.padding = kScreenContentPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: padding,
        child: child,
      ),
    );
  }
}
