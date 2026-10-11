import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

class ReceivePaymentView extends StatefulWidget {
  const ReceivePaymentView({super.key});

  @override
  State<ReceivePaymentView> createState() => _ReceivePaymentViewState();
}

class _ReceivePaymentViewState extends State<ReceivePaymentView> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(top: false, child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Receive payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(
            'Today, ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: cs.onSurfaceVariant),
          ),
        ],
      ),
    )));
  }
}
