import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/date_time_helper.dart';
import '../../../helpers/number_helper.dart';
import '../../../helpers/responsive.dart';
import '../../../models/collection_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/invoice_model.dart';
import '../../../services/database/db_constants.dart';
import '../../../shared/enum.dart';
import '../../../shared/widgets/overflow_marquee_text.dart';
import '../../../shared/widgets/pay_mode_selection.dart';
import '../../../shared/widgets/responsive_grid.dart';

class CollectionUiHelper {
  final BuildContext context;
  const CollectionUiHelper._(this.context);
  static CollectionUiHelper of(BuildContext context) =>
      CollectionUiHelper._(context);

  ColorScheme get _colorScheme => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;
  Responsive get _responsive => Responsive.of(context);

  Color rowStatusColor(RowStatus status, {bool selected = false}) {
    if (selected) {
      return _colorScheme.primary;
    }

    return switch (status) {
      RowStatus.UNL => Colors.green,
      RowStatus.LCK => Colors.red,
      RowStatus.ENA => Colors.blueGrey,
      RowStatus.DIS => Colors.grey,
    };
  }

  Icon rowStatusIcon(
    RowStatus status, {
    required bool selected,
    bool multiSelect = false,
  }) {
    final color = selected
        ? _colorScheme.primary
        : switch (status) {
            .UNL => Colors.green,
            .LCK => Colors.red,
            .ENA => Colors.blueGrey,
            .DIS => Colors.grey,
          };

    final icon = selected
        ? (multiSelect ? Icons.check_box : Icons.check_circle)
        : switch (status) {
            .UNL => Icons.lock_open_rounded,
            .LCK => Icons.lock_rounded,
            .ENA =>
              (multiSelect
                  ? Icons.check_box_outline_blank
                  : Icons.check_circle_outline_rounded),
            .DIS => Icons.disabled_visible_rounded,
          };

    return Icon(icon, color: color);
  }

  Widget payModeChip(PayMode payMode, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: .symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: _colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          spacing: 4,
          children: [
            Text(payMode.label),
            if (onTap != null) Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget summaryTextRow(
    String label,
    String value, {
    Color? valueColor,
    Widget? valueChild,
    bool isEmphasized = false,
  }) {
    final labelStyle = _textTheme.bodyMedium?.copyWith(
      fontWeight: isEmphasized ? FontWeight.w600 : FontWeight.w400,
      color: _colorScheme.secondary,
    );

    final valueStyle =
        (isEmphasized ? _textTheme.titleMedium : _textTheme.bodyMedium)
            ?.copyWith(
              fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? _colorScheme.onSurface,
            );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          Flexible(
            flex: _responsive.isPhone ? 1 : 2,
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          valueChild ??
              Flexible(
                flex: _responsive.isPhone ? 1 : 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OverflowMarqueeText(text: value, style: valueStyle),
                ),
              ),
        ],
      ),
    );
  }

  Widget summaryLargeTextRow(
    String label,
    String value, {
    Color? valueColor,
    Widget? valueChild,
    TextAlign? textAlign = TextAlign.end,
  }) {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.end;
    late AlignmentGeometry valueAlignment;

    switch (textAlign) {
      case TextAlign.start:
        valueAlignment = Alignment.topLeft;
        break;
      case TextAlign.end:
        valueAlignment = Alignment.topRight;
        break;
      default:
        valueAlignment = Alignment.topLeft;
    }

    final labelStyle = _textTheme.bodyLarge?.copyWith(
      color: _colorScheme.secondary,
    );

    final valueStyle = _textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: valueColor,
    );

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle,
            textAlign: textAlign,
            // maxLines: 1,
            // overflow: TextOverflow.ellipsis,
          ),
        ),
        valueChild ??
            Expanded(
              child: Align(
                alignment: valueAlignment,
                child: OverflowMarqueeText(text: value, style: valueStyle),
              ),
            ),
      ],
    );
  }

  Widget summaryIconRow(
    String label,
    IconData icon,
    String value, {
    Color? iconColor,
    Color? valueColor,
    Widget? valueChild,
    bool isEmphasized = false,
  }) {
    final labelStyle = _textTheme.bodyMedium?.copyWith(
      fontWeight: isEmphasized ? FontWeight.w600 : FontWeight.w400,
      color: _colorScheme.secondary,
    );

    final valueStyle =
        (isEmphasized ? _textTheme.titleMedium : _textTheme.bodyMedium)
            ?.copyWith(
              fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? _colorScheme.onSurface,
            );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        spacing: 12,
        children: [
          Flexible(
            flex: _responsive.isPhone ? 1 : 2,
            child: Row(
              mainAxisSize: .min,
              spacing: 12,
              children: [
                Container(
                  width: isEmphasized ? 32 : 24,
                  height: isEmphasized ? 32 : 24,
                  decoration: BoxDecoration(
                    color: (iconColor ?? _colorScheme.primary).withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: iconColor ?? _colorScheme.primary,
                    size: isEmphasized ? 16 : 14,
                  ),
                ),
                Flexible(
                  child: Text(
                    label,
                    style: labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          valueChild ??
              Flexible(
                flex: _responsive.isPhone ? 1 : 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OverflowMarqueeText(text: value, style: valueStyle),
                ),
              ),
        ],
      ),
    );
  }

  Widget summaryBox(
    String label,
    IconData icon,
    String value, {
    Color? valueColor,
    Color? iconColor,
    Widget? valueChild,
    bool isFilled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFilled ? _colorScheme.surfaceContainer : null,
        borderRadius: BorderRadius.circular(12),
        border: isFilled
            ? null
            : Border.all(color: _colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (iconColor ?? _colorScheme.primary).withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor ?? _colorScheme.primary,
              size: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _colorScheme.secondary,
                  ),
                  overflow: .ellipsis,
                ),
                valueChild ??
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: valueColor,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget setOffTile(
      CollectionSetOffModel setOff,
      bool selected, {
        Function(CollectionSetOffModel setOff)? onRemove,
      }) {
    final colorScheme = _colorScheme;
    final textTheme = _textTheme;

    late final String title;
    late final String chipText; // the "What type" pill
    late final String amountLabel;
    late final IconData icon;
    late final Color color;

    switch (setOff.recType) {
      case DBConstants.DOC_INVOICE:
        title = 'Invoice Setoff';
        chipText = setOff.recDoc;
        amountLabel = 'Setoff Amount';
        icon = Icons.receipt_long_outlined;
        color = const Color(0xFF0D9488);
        break;

      case DBConstants.DOC_CASH_DISCOUNT:
        title = 'Cash Discount';
        chipText = NumberHelper.discountFormat(setOff.discount);
        amountLabel = 'Setoff Amount';
        icon = Icons.payments_outlined;
        color = const Color(0xFF16A34A);
        break;

      case DBConstants.DOC_BULK_DISCOUNT:
        title = 'Bulk Discount';
        chipText = NumberHelper.discountFormat(setOff.discount);
        amountLabel = 'Setoff Amount';
        icon = Icons.inventory_2_outlined;
        color = const Color(0xFF2563EB);
        break;

      case DBConstants.DOC_CREDIT_NOTE:
        title = 'Credit Applied';
        chipText = '${setOff.recDoc}-${setOff.recNo}';
        amountLabel = 'Setoff Amount';
        icon = Icons.account_balance_wallet_outlined;
        color = const Color(0xFF9333EA);
        break;

      default:
        title = 'Set-off';
        chipText = setOff.recDoc;
        amountLabel = 'Setoff Amount';
        icon = Icons.info_outline_rounded;
        color = colorScheme.onSurfaceVariant;
    }

    final invoiceNumber = '${setOff.invDoc}-${setOff.invNo}';
    final amount = NumberHelper.formatCurrency(setOff.setOffAmount.abs());

    final createdAt = setOff.createdAt;
    final timeText = createdAt != null ? DateFormat('hh:mm a').format(createdAt) : '-';

    final lightColor = color.withValues(alpha: 0.14);
    final borderColor = selected
        ? color
        : colorScheme.outlineVariant.withValues(alpha: 0.45);

    // ── Shared pieces ────────────────────────────────────────────────

    Widget leadingIcon({required double size}) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: lightColor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.5, color: color),
      );
    }

    Widget cardTitle() {
      return Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          if (onRemove != null)
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                tooltip: 'Remove $title',
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: () => onRemove.call(setOff),
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      );
    }

    Widget typeChip() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          chipText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    Widget infoItem(IconData leading, String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leading, size: 22, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 96),
                  // color: Colors.red,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Invoice + transaction date; wraps to two lines if space is tight.
    Widget infoRow() {
      return Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          infoItem(Icons.description_outlined, 'Invoice', invoiceNumber),
          // infoItem(Icons.calendar_today_outlined, 'Date', dateText),
          infoItem(Icons.access_time_rounded, 'Time', timeText),
        ],
      );
    }

    Widget amountSection({required bool center}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            amountLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: center ? Alignment.center : Alignment.centerLeft,
            child: Text(
              amount,
              maxLines: 1,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                // fontSize: 20,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      );
    }

    // ── Mobile (< 600): icon | title, chip, invoice | divider | amount ──

    Widget mobileLayout() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leadingIcon(size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                cardTitle(),
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerLeft, child: typeChip()),
                const SizedBox(height: 10),
                infoRow(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 52,
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 90, maxWidth: 130),
            child: amountSection(center: true),
          ),
        ],
      );
    }

    // ── Tablet (>= 600): stacked card ────────────────────────────────

    Widget tabletLayout() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leadingIcon(size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cardTitle(),
                    const SizedBox(height: 6),
                    Align(alignment: Alignment.centerLeft, child: typeChip()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 14),
          infoRow(),
          const SizedBox(height: 14),
          amountSection(center: false),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            // Mobile: clean white card. Tablet: soft tinted gradient.
            color: isMobile ? colorScheme.surface : null,
            gradient: isMobile
                ? null
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: selected ? 0.14 : 0.10),
                color.withValues(alpha: selected ? 0.06 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(
            //   color: isMobile && !selected
            //       ? Colors.transparent
            //       : (selected ? color : color.withValues(alpha: 0.18)),
            //   width: selected ? 1.5 : 1,
            // ),
            boxShadow: [
              BoxShadow(
                color: (isMobile ? Colors.black : color)
                    .withValues(alpha: selected ? 0.12 : 0.06),
                blurRadius: selected ? 14 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isMobile ? mobileLayout() : tabletLayout(),
        );
      },
    );
  }

  Widget setOffTile2(
    CollectionSetOffModel setOff,
    bool selected, {
    Function(CollectionSetOffModel setOff)? onRemove,
  }) {
    String title = '';
    String amountLabel = '';
    String detailLabel = '';
    String detailValue = '';
    IconData icon = Icons.info_rounded;
    Color color = Colors.grey;

    if (setOff.recType == DBConstants.DOC_INVOICE) {
      title = 'Invoice Set-off';
      amountLabel = 'Set Off Amount';
      detailLabel = 'Document';
      detailValue = setOff.recDoc;
      icon = Icons.receipt_long_outlined;
      color = Color(0xFF0D9488);
    } else if (setOff.recType == DBConstants.DOC_CASH_DISCOUNT) {
      title = 'Cash Discount';
      amountLabel = 'Discount Amount';
      detailLabel = 'Discount';
      detailValue = NumberHelper.discountFormat(setOff.discount);
      icon = Icons.payments_outlined;
      color = Color(0xFF16A34A);
    } else if (setOff.recType == DBConstants.DOC_BULK_DISCOUNT) {
      title = 'Bulk Discount';
      amountLabel = 'Discount Amount';
      detailLabel = 'Discount';
      detailValue = NumberHelper.discountFormat(setOff.discount);
      icon = Icons.inventory_2_outlined;
      color = Color(0xFF2563EB);
    } else if (setOff.recType == DBConstants.DOC_CREDIT_NOTE) {
      title = 'Invoice Set-off';
      amountLabel = 'Credit Amount';
      detailLabel = 'Credit Note';
      detailValue = '${setOff.recDoc}${setOff.recNo}';
      icon = Icons.account_balance_wallet_outlined;
      color = Color(0xFF9333EA);
    }

    Widget subtitleChip(String label, String value) {
      return Container(
        width: 144,
        margin: .only(top: 4, bottom: 4),
        padding: .symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _colorScheme.outlineVariant),

          // borderRadius: BorderRadius.only(
          //   topRight: Radius.circular(12),
          //   bottomRight: Radius.circular(12),
          // ),
          // border: Border(
          //   top: BorderSide(color: _colorScheme.outlineVariant),
          //   right: BorderSide(color: _colorScheme.outlineVariant),
          //   bottom: BorderSide(color: _colorScheme.outlineVariant),
          // ),
          color: _colorScheme.surfaceContainerLow,
        ),
        child: Column(
          crossAxisAlignment: .center,
          children: [
            Text(
              label,
              style: TextStyle(color: _colorScheme.onPrimaryContainer),
            ),
            Text(value),
          ],
        ),
      );
    }

    Widget leadingIcon() {
      final double size = 48;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: size / 2),
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: 72),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        border: Border(right: BorderSide(color: color, width: 2)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxDetailWidth = 350;
              final bool isPhone = constraints.maxWidth <= 500;

              return Row(
                spacing: 4,
                children: [
                  if (!isPhone)
                    Container(padding: .all(12), child: leadingIcon()),
                  Flexible(
                    child: Container(
                      // color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .start,
                        spacing: 8,
                        children: [
                          Row(
                            crossAxisAlignment: .start,
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Row(
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 144,
                                    padding: .symmetric(
                                      vertical: 4,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.start,
                                      style: _textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentGeometry.bottomRight,
                            child: Container(
                              // color: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 8,
                              ),
                              width: isPhone ? .infinity : maxDetailWidth,
                              child: Column(
                                children: [
                                  summaryTextRow(
                                    'Invoice',
                                    '${setOff.invDoc}${setOff.invNo}',
                                  ),
                                  summaryTextRow(
                                    detailLabel,
                                    detailValue,
                                    valueColor: _colorScheme.onPrimaryContainer,
                                  ),
                                  summaryTextRow(
                                    amountLabel,
                                    NumberHelper.formatCurrency(
                                      setOff.setOffAmount,
                                    ),
                                    valueColor: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (onRemove != null)
            Align(
              alignment: .topRight,
              child: IconButton(
                onPressed: () => onRemove.call(setOff),
                icon: Icon(Icons.cancel),
                style: IconButton.styleFrom(
                  // visualDensity: .compact,
                  tapTargetSize: .shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget documentTile(
      bool selected,
      bool multiSelect, {
        required RowStatus rowSts,
        required String docCode,
        required String docNo,
        required String txnDate,
        required double balance,
        double amount = 0,
        double cashDiscount = 0,
        double currentCashDiscount = 0,
        double bulkDiscount = 0,
        double currentBulkDiscount = 0,
        String? locName,
      }) {
    final colorScheme = _colorScheme;
    final textTheme = _textTheme;

    final statusColor = rowStatusColor(rowSts, selected: selected);
    final isSettled = balance == 0;

    const appliedColor = Color(0xFF9333EA); // discount already applied
    const currentColor = Color(0xFF2563EB); // discount for current entry
    const settledColor = Color(0xFF16A34A);
    const pendingColor = Color(0xFFD97706);

    final balanceColor = isSettled ? settledColor : pendingColor;

    // ── Small building blocks ────────────────────────────────────────

    Widget pill({
      required String text,
      required Color color,
      IconData? icon,
      String? suffix,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Text(
                suffix,
                style: textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.75),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget discountPill(String label, double applied, double current) {
      if (applied > 0) {
        return pill(
          text: '$label ${NumberHelper.discountFormat(applied)}',
          color: appliedColor,
          icon: Icons.check_circle_outline_rounded,
          suffix: 'Applied',
        );
      }
      if (current > 0) {
        return pill(
          text: '$label ${NumberHelper.discountFormat(current)}',
          color: currentColor,
          icon: Icons.local_offer_outlined,
          suffix: 'Current',
        );
      }
      return const SizedBox.shrink();
    }

    Widget statBlock(
        String label,
        String value,
        Color color, {
          CrossAxisAlignment align = CrossAxisAlignment.start,
        }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: align == CrossAxisAlignment.end
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      );
    }

    // ── Header: status icon | doc number + date | "Set off" badge ────

    Widget header() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          rowStatusIcon(rowSts, selected: selected, multiSelect: multiSelect),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$docCode$docNo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        txnDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSettled) ...[
            const SizedBox(width: 8),
            pill(
              text: 'Set off',
              color: settledColor,
              icon: Icons.task_alt_rounded,
            ),
          ],
        ],
      );
    }

    // ── Tags: location + discounts (only rendered when present) ──────

    Widget? tags() {
      final items = <Widget>[
        if (locName != null && locName.isNotEmpty)
          pill(
            text: locName,
            color: colorScheme.onSurfaceVariant,
            icon: Icons.location_on_outlined,
          ),
        if (cashDiscount > 0 || currentCashDiscount > 0)
          discountPill('Cash Discount', cashDiscount, currentCashDiscount),
        if (bulkDiscount > 0 || currentBulkDiscount > 0)
          discountPill('Bulk Discount', bulkDiscount, currentBulkDiscount),
      ];
      if (items.isEmpty) return null;
      return Wrap(spacing: 8, runSpacing: 8, children: items);
    }

    Widget thinDivider() => Divider(
      height: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
    );

    // ── Mobile: everything stacked, amounts in one row at the bottom ─

    Widget mobileLayout() {
      final tagWidget = tags();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          header(),
          if (tagWidget != null) ...[
            const SizedBox(height: 12),
            tagWidget,
          ],
          const SizedBox(height: 12),
          thinDivider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: statBlock(
                  'Total Amount',
                  NumberHelper.formatCurrency(amount),
                  colorScheme.onSurface,
                ),
              ),
              Expanded(
                child: statBlock(
                  'Balance',
                  NumberHelper.formatCurrency(balance),
                  balanceColor,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ── Tablet: details on the left, amounts on the right ────────────

    Widget tabletLayout() {
      final tagWidget = tags();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                header(),
                if (tagWidget != null) ...[
                  const SizedBox(height: 12),
                  tagWidget,
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 64,
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 130, maxWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                statBlock(
                  'Total Amount',
                  NumberHelper.formatCurrency(amount),
                  colorScheme.onSurface,
                  align: CrossAxisAlignment.end,
                ),
                const SizedBox(height: 10),
                statBlock(
                  'Balance',
                  NumberHelper.formatCurrency(balance),
                  balanceColor,
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: selected
                ? statusColor.withValues(alpha: 0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? statusColor
                  : colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: selected ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: selected ? 0.14 : 0.07),
                blurRadius: selected ? 14 : 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isMobile ? mobileLayout() : tabletLayout(),
        );
      },
    );
  }

  Widget documentTile2(
    bool selected,
    bool multiSelect, {
    required RowStatus rowSts,
    required String docCode,
    required String docNo,
    required String txnDate,
    required double balance,
    double amount = 0,
    double cashDiscount = 0,
    double currentCashDiscount = 0,
    double bulkDiscount = 0,
    double currentBulkDiscount = 0,
    // double discount = 0,
    // double appliedDiscount = 0,
    String? locName,
  }) {
    Widget discountChip(String label, double value, Color color) {
      return Container(
        padding: .all(2),
        decoration: BoxDecoration(color: color, borderRadius: .circular(8)),
        child: Row(
          mainAxisSize: .min,
          children: [
            Container(
              padding: .symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: _colorScheme.surface,
                borderRadius: .circular(6),
              ),
              child: Text(label, style: TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const .fromLTRB(6, 2, 4, 2),
              child: Text(
                '$value %',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: rowStatusColor(rowSts, selected: selected),
            width: 3,
          ),
        ),
        borderRadius: .circular(12),
        boxShadow: [
          BoxShadow(
            color: rowStatusColor(
              rowSts,
              selected: selected,
            ).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: .fromLTRB(8, 0, 0, 4),
        minVerticalPadding: 0,
        titleAlignment: .top,
        leading: Padding(
          padding: const .only(top: 8),
          child: rowStatusIcon(
            rowSts,
            selected: selected,
            multiSelect: multiSelect,
          ),
        ),
        title: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text("$docCode$docNo", style: _textTheme.titleSmall),
                  Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        "Transaction ",
                        style: _textTheme.bodySmall?.copyWith(
                          color: _colorScheme.secondary,
                        ),
                      ),
                      Text(
                        txnDate,
                        style: _textTheme.bodySmall?.copyWith(
                          color: _colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 4,
              children: [
                if (balance == 0) ...[
                  Container(
                    padding: .symmetric(vertical: 2, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: .circular(8),
                      color: Colors.green,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Set off',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                // Align(
                //   alignment: .topRight,
                //   child: IconButton(
                //     onPressed: () {},
                //     icon: Icon(Icons.more_vert_rounded),
                //   ),
                // ),
              ],
            ),
          ],
        ),
        subtitle: Container(
          // color: Colors.pink.shade50,
          // margin: const .only(right: 8),
          padding: const .only(right: 8),
          // width: 399,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = 460;

              Widget detailSection = Container(
                width: 180,
                // color: Colors.red,
                padding: const .only(top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .end,
                  spacing: 8,
                  children: [
                    // if (cashDiscount > 0)
                    //   discountChip('Cash Discount', cashDiscount, Colors.purple)
                    // else if (currentCashDiscount > 0)
                    //   discountChip('Cash Discount', currentCashDiscount, Colors.blue)
                    // else
                    //   const SizedBox.shrink(),
                    //
                    // if (bulkDiscount > 0)
                    //   discountChip('Bulk Discount', bulkDiscount, Colors.purple)
                    // else if (currentBulkDiscount > 0)
                    //   discountChip('Bulk Discount', currentBulkDiscount, Colors.blue)
                    // else
                    //   const SizedBox.shrink(),
                  ],
                ),
              );

              Widget amountSection = Container(
                width: 280,
                // color: Colors.blue.shade50,
                padding: const .only(top: 4, bottom: 4),
                child: Column(
                  children: [
                    if (locName != null && locName.isNotEmpty) ...[
                      summaryTextRow('Location', locName),
                      Divider(height: 8, thickness: 0.6),
                    ],

                    if (cashDiscount > 0)
                      summaryTextRow('Cash Discount', NumberHelper.discountFormat(cashDiscount), valueColor: Colors.purple)
                    else if (currentCashDiscount > 0)
                      summaryTextRow('Cash Discount', NumberHelper.discountFormat(currentCashDiscount), valueColor: Colors.blue)
                    else
                      const SizedBox.shrink(),

                    if (bulkDiscount > 0)
                      summaryTextRow('Bulk Discount', NumberHelper.discountFormat(bulkDiscount), valueColor: Colors.purple)
                    else if (currentBulkDiscount > 0)
                      summaryTextRow('Bulk Discount', NumberHelper.discountFormat(currentBulkDiscount), valueColor: Colors.blue)
                    else
                      const SizedBox.shrink(),


                    summaryTextRow(
                      'Total Amount',
                      NumberHelper.formatCurrency(amount),
                    ),
                    summaryTextRow(
                      'Balance',
                      NumberHelper.formatCurrency(balance),
                    ),
                  ],
                ),
              );

              if (maxWidth > constraints.maxWidth) {
                return Column(
                  crossAxisAlignment: .stretch,
                  // spacing: 4,
                  children: [
                    Align(alignment: .topLeft, child: detailSection),
                    Align(alignment: .bottomRight, child: amountSection),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: .end,
                  mainAxisAlignment: .spaceBetween,
                  mainAxisSize: .max,
                  children: [detailSection, amountSection],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget invoiceDetailHeader(
    InvoiceModel invoice, {
    double? maxDiscount,
    bool showDiscount = false,
    bool showCurrentBalance = false,
    bool showAppliedDiscount = false,
    bool showAppliedCreditAmount = false,
    bool showMaxDiscount = false,
  }) {
    return Column(
      mainAxisSize: .min,
      spacing: 8,
      children: [
        summaryTextRow('Invoice Number', '${invoice.docCode}${invoice.docNo}'),
        summaryTextRow('Transaction Date', '${invoice.txnDate}'),
        if (invoice.cashDiscount > 0 && showDiscount)
          summaryTextRow(
            'Discount',
            NumberHelper.discountFormat(invoice.cashDiscount),
          ),
        summaryTextRow(
          'Invoice Amount ',
          NumberHelper.formatCurrency(invoice.originalAmount),
        ),
        if (showCurrentBalance)
          summaryTextRow(
            'Current Balance',
            NumberHelper.formatCurrency(invoice.balanceAmount),
          ),
        if (maxDiscount != null && showMaxDiscount)
          summaryTextRow(
            'Maximum Discount',
            NumberHelper.discountFormat(maxDiscount),
          ),
        if (invoice.currentCashDiscount != 0 && showAppliedDiscount) ...[
          summaryIconRow(
            'Cash Discount',
            Icons.done,
            NumberHelper.discountFormat(invoice.currentCashDiscount),
            iconColor: Colors.blue,
            valueColor: Colors.blue,
          ),
          summaryIconRow(
            'Cash Discount Amount',
            Icons.done,
            NumberHelper.formatCurrency(invoice.currentCashDiscountAmount),
            iconColor: Colors.blue,
            valueColor: Colors.green,
          ),
        ],
        if (invoice.currentBulkDiscount != 0 && showAppliedDiscount) ...[
          summaryIconRow(
            'Bulk Discount',
            Icons.done,
            NumberHelper.discountFormat(invoice.currentBulkDiscount),
            iconColor: Colors.blue,
            valueColor: Colors.blue,
          ),
          summaryIconRow(
            'Bulk Discount Amount',
            Icons.done,
            NumberHelper.formatCurrency(invoice.currentBulkDiscountAmount),
            iconColor: Colors.blue,
            valueColor: Colors.green,
          ),
        ],
        if (invoice.currentCreditAmount != 0 && showAppliedCreditAmount)
          summaryIconRow(
            'Credit Applied',
            Icons.done,
            NumberHelper.formatCurrency(invoice.currentCreditAmount),
            iconColor: Colors.green,
            valueColor: Colors.red,
          ),
      ],
    );
  }

  Widget invoiceDetailLargeHeader(
    InvoiceModel invoice, {
    bool showCashDiscount = false,
    bool showBulkDiscount = false,

    bool showCurrentBalance = false,
    bool showAppliedDiscount = false,
    bool showAppliedCreditAmount = false,
    bool showMaxDiscount = false,
  }) {
    return Column(
      mainAxisSize: .min,
      spacing: 12,
      children: [
        summaryLargeTextRow(
          'Invoice Number',
          '${invoice.docCode}${invoice.docNo}',
        ),
        summaryLargeTextRow(
          'Transaction Date',
          DateTimeHelper.getDisplayDate(invoice.txnDate),
        ),
        if (invoice.cashDiscount > 0 && showCashDiscount)
          summaryLargeTextRow(
            'Cash Discount',
            NumberHelper.discountFormat(invoice.cashDiscount),
          ),
        if (invoice.bulkDiscount > 0 && showBulkDiscount)
          summaryLargeTextRow(
            'Bulk Discount',
            NumberHelper.discountFormat(invoice.bulkDiscount),
          ),
        summaryLargeTextRow(
          'Invoice Amount',
          NumberHelper.formatCurrency(invoice.originalAmount),
        ),
        // if (showCurrentBalance)
        summaryLargeTextRow(
          'Invoice Balance',
          NumberHelper.formatCurrency(invoice.balanceAmount),
        ),

        // if (invoice.appliedCashDiscount != 0 && showAppliedDiscount) ...[
        //   summaryIconRow(
        //     'Discount',
        //     Icons.done,
        //     NumberHelper.discountFormat(invoice.appliedCashDiscount),
        //     iconColor: Colors.green,
        //     valueColor: Colors.green,
        //   ),
        //   summaryIconRow(
        //     'Discount Amount',
        //     Icons.done,
        //     NumberHelper.formatCurrency(invoice.appliedCashDiscountAmount),
        //     iconColor: Colors.green,
        //     valueColor: Colors.red,
        //   ),
        // ],
        // if (invoice.appliedCreditAmount != 0 && showAppliedCreditAmount)
        //   summaryIconRow(
        //     'Credit Applied',
        //     Icons.done,
        //     NumberHelper.formatCurrency(invoice.appliedCreditAmount),
        //     iconColor: Colors.green,
        //     valueColor: Colors.red,
        //   ),
      ],
    );
  }

  /*Widget receiptProgressCard(double progress) => Card(
    margin: .zero,
    color: _colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            // 'Set-Off Progress ( ${progress.toStringAsFixed(2)}%${progress > 0 ? ' complete' : ''})',
            'Receipt Set-Off Progress ( ${progress.toStringAsFixed(2)}% )',
            style: _textTheme.bodySmall?.copyWith(
              color: _colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress * 0.01,
            minHeight: 6,
            color: progress < 100 ? _colorScheme.primary : Colors.green,
            backgroundColor: _colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    ),
  );*/

  Widget receiptSummaryHeader({
    required CustomerModel? customer,
    required PaymentDetails? paymentDetails,
    required double receiptAmount,
    required double setOffAmount,
  }) {
    return Column(
      spacing: 8,
      mainAxisAlignment: .center,
      children: [
        summaryIconRow(
          'Customer',
          Icons.person_outline,
          '${customer?.csCode} - ${customer?.csName}',
        ),
        summaryIconRow(
          'Payment Mode',
          Icons.payments_outlined,
          '',
          valueChild: payModeChip(
            paymentDetails?.payMode ?? PayMode.none,
            onTap:
                [
                      PayMode.cash,
                      PayMode.none,
                    ].contains(paymentDetails?.payMode) ||
                    paymentDetails == null
                ? null
                : () => showPaymentDetailSheet(paymentDetails),
          ),
        ),
        summaryIconRow(
          'Receipt Amount',
          Icons.receipt_long_outlined,
          NumberHelper.formatCurrency(receiptAmount),
        ),
        summaryIconRow(
          'Set-Off Amount',
          Icons.account_balance_wallet_outlined,
          NumberHelper.formatCurrency(setOffAmount),
          valueColor: Colors.red,
          // isEmphasized: true
        ),
      ],
    );
  }

  Widget paymentDetailWidget(PaymentDetails details) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const .all(24),
        child: ResponsiveGrid(
          tabletColumns: 2,
          desktopColumns: 3,
          spacing: 12,
          children: [
            CollectionUiHelper.of(context).summaryBox(
              'Payment Mode',
              Icons.receipt_long_rounded,
              details.payMode?.label ?? 'N/A',
              isFilled: true,
            ),

            if (details.payMode == .cheque) ...[
              CollectionUiHelper.of(context).summaryBox(
                'Cheque Number',
                Icons.receipt_long_rounded,
                details.chqNumber ?? 'N/A',
              ),
              CollectionUiHelper.of(context).summaryBox(
                'Cheque Date',
                Icons.calendar_today_rounded,
                details.chqDate ?? 'N/A',
              ),
              CollectionUiHelper.of(context).summaryBox(
                'Bank Name',
                Icons.account_balance_rounded,
                details.bank?.bankName ?? 'N/A',
              ),
              CollectionUiHelper.of(context).summaryBox(
                'Branch Name',
                Icons.account_balance_outlined,
                details.branch?.branchName ?? 'N/A',
              ),
            ],

            if (details.payMode == .ddCash || details.payMode == .ddCheque) ...[
              CollectionUiHelper.of(context).summaryBox(
                'Reference Number',
                Icons.tag_rounded,
                details.ddRefNumber ?? 'N/A',
              ),
            ],
          ],
        ),
      ),
    );
  }

  void showPaymentDetailSheet(PaymentDetails details) =>
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        builder: (context) => paymentDetailWidget(details),
      );

  Widget buildSummaryFooterRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            textAlign: .end,
            style: _textTheme.bodyLarge?.copyWith(
              color: _colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: .end,
            style: _textTheme.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: .w500,
            ),
          ),
        ),
      ],
    );
  }
}
