import 'package:flutter/material.dart';

/// Виджет нативной кнопки оплаты Сбербанка
class SberPayButton extends StatelessWidget {
  const SberPayButton({
    super.key,
    this.onPressed,
  });

  /// Обработчик нажатия на кнопку
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF21A038),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Оплатить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'SberPaySans',
                    package: 'sber_pay',
                  ),
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
      ),
    );
  }
}
