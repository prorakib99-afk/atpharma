import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/utils/currency_display.dart';

class CurrencyAmount extends StatelessWidget {
  const CurrencyAmount({
    super.key,
    required this.value,
    required this.style,
    this.currencyCode,
    this.countryCode,
  });

  final num value;
  final TextStyle style;
  final String? currencyCode;
  final String? countryCode;

  @override
  Widget build(BuildContext context) {
    if (!CurrencyDisplay.isSaudi(
      currencyCode: currencyCode,
      countryCode: countryCode,
    )) {
      return Text(
        CurrencyDisplay.format(
          value,
          currencyCode: currencyCode,
          countryCode: countryCode,
        ),
        style: style,
      );
    }

    final double fontSize = style.fontSize ?? 14;
    final Color color =
        style.color ?? DefaultTextStyle.of(context).style.color!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          'assets/icons/saudi_riyal_symbol.svg',
          width: fontSize * .72,
          height: fontSize * .8,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 2),
        Text(CurrencyDisplay.amount(value), style: style),
      ],
    );
  }
}
