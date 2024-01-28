import 'package:sber_pay_platform_interface/types/sber_pay_env.dart';

/// Конфигурация инициализации
class SberPayInitConfig {
  const SberPayInitConfig({
    required this.env,
    required this.enableBnpl,
  });

  /// Среда запуска
  final SberPayEnv env;

  /// Использование функционала оплаты частями
  final bool? enableBnpl;
}
