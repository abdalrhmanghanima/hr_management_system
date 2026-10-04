import 'package:flutter/material.dart';
import 'package:hr_management_system/core/app_theme/app_colors.dart';
import 'package:hr_management_system/core/extensions/num_extensions.dart';
import 'package:hr_management_system/core/responsive/breakpoints.dart';

/// Constrains its child to [maxWidth] and centers it horizontally.
///
/// The constraint only takes effect once the incoming width exceeds
/// [maxWidth], so on mobile the layout stays exactly the same.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    required this.maxWidth,
    required this.child,
    this.center = true,
    this.applyFromWidth = 0,
  });

  final double maxWidth;
  final Widget child;
  final bool center;

  /// When > 0 the constraint is only applied if the screen width is at least
  /// this value (e.g. only on desktop).
  final double applyFromWidth;

  @override
  Widget build(BuildContext context) {
    if (applyFromWidth > 0 && context.screenWidth < applyFromWidth) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final incoming = constraints.maxWidth;

        // Constraint does not bind: keep the original layout untouched.
        if (incoming.isFinite && incoming <= maxWidth) {
          return child;
        }

        final constrained = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        );

        return center ? Center(child: constrained) : constrained;
      },
    );
  }
}

/// A vertical list of equal cards that automatically uses multiple columns
/// when the available width allows it.
///
/// With a single column it behaves exactly like the original
/// `ListView.separated` used by the mobile design.
class AdaptiveCardList extends StatelessWidget {
  const AdaptiveCardList({
    super.key,
    required this.children,
    this.spacing = 16,
    this.columnSpacing,
    this.minCardWidth = 340,
    this.maxColumns = 3,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  /// Pre-built card widgets.
  final List<Widget> children;

  /// Gap between cards (vertical and horizontal).
  final double spacing;

  /// Gap between columns; defaults to [spacing].
  final double? columnSpacing;

  /// Minimum comfortable width of a single card column.
  final double minCardWidth;

  /// Upper bound of columns regardless of width.
  final int maxColumns;

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  int _columnsFor(double maxWidth, double gap) {
    if (maxWidth.isInfinite || maxWidth <= 0) return 1;
    final fit = ((maxWidth + gap) / (minCardWidth + gap)).floor();
    return fit.clamp(1, maxColumns);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hGap = columnSpacing ?? spacing;
        final columns = _columnsFor(constraints.maxWidth, hGap);

        if (columns <= 1) {
          return ListView.separated(
            padding: padding ?? EdgeInsets.zero,
            physics: physics,
            shrinkWrap: shrinkWrap,
            itemCount: children.length,
            separatorBuilder: (context, index) => SizedBox(height: spacing),
            itemBuilder: (context, index) => children[index],
          );
        }

        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final rowChildren = <Widget>[];
          for (var offset = 0; offset < columns; offset++) {
            final index = start + offset;
            if (index >= children.length) break;
            if (rowChildren.isNotEmpty) {
              rowChildren.add(SizedBox(width: hGap));
            }
            rowChildren.add(Expanded(child: children[index]));
          }

          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );

          if (start + columns < children.length) {
            rows.add(SizedBox(height: spacing));
          }
        }

        return ListView(
          padding: padding ?? EdgeInsets.zero,
          physics: physics,
          shrinkWrap: shrinkWrap,
          children: rows,
        );
      },
    );
  }
}

/// Lays out form fields in a single column on mobile and in multiple
/// columns per row when enough width is available.
class AdaptiveFormRow extends StatelessWidget {
  const AdaptiveFormRow({super.key, required this.children, this.spacing});

  final List<Widget> children;

  /// Gap between fields; defaults to `16.h` (the original form spacing).
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = spacing ?? 16.h;
        final canUseRow =
            children.length > 1 &&
            constraints.maxWidth.isFinite &&
            constraints.maxWidth >= AppBreakpoints.formRowMinWidth;

        if (!canUseRow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

/// Wraps bottom-sheet content so that on tablet/desktop the sheet becomes a
/// reasonably sized, centered panel instead of stretching across the window.
///
/// On mobile the child is returned unchanged.
class ResponsiveSheetContent extends StatelessWidget {
  const ResponsiveSheetContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sheet = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: child,
    );

    if (!context.isLargeScreenDevice) {
      return sheet;
    }

    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.bottomSheetMaxWidth,
        ),
        child: sheet,
      ),
    );
  }
}
