import 'package:flutter/material.dart';

const String viewType = 'sber_pay_button';

/// Виджет рисует нативную кнопку оплаты Сбербанка
class SberPayButton extends StatelessWidget {
  const SberPayButton({
    super.key,
    this.onPressed,
  });

  /// Обработчик нажатия на кнопку
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed?.call(),
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF21A038),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Оплатить',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'SberPaySans',
                package: 'sber_pay',
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/sberpay_logo.png',
              package: 'sber_pay',
              width: 48,
              height: 22,
            ),
          ],
        ),
      ),
    );
  }
}
