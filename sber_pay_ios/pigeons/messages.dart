import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/Classes/Messages.g.swift',
  ),
)

/// Тип инициализации сервисов Сбербанка
enum SberPayApiEnv {
  /// Продуктовый режим.
  ///
  /// Для авторизации пользователя происходит редирект в приложение Сбербанка.
  prod,

  /// Режим песочницы.
  ///
  /// Позволяет протестировать оплату как в [prod], но с тестовыми данными.
  sandboxRealBankApp,

  /// Режим песочницы без перехода в банк.
  ///
  /// При авторизации пользователя не осуществляется переход в приложение
  /// Сбербанка.
  sandboxWithoutBankApp
}

/// Статусы оплаты
enum SberPayApiPaymentStatus {
  /// Успешный результат
  success,

  /// Необходимо проверить статус оплаты
  processing,

  /// Пользователь отменил оплату
  cancel,

  /// Неизвестный тип
  unknown;
}

/// Конфигурация инициализации
class InitConfig {
  const InitConfig({
    required this.env,
    required this.enableBnpl,
  });

  /// Среда запуска
  final SberPayApiEnv env;

  /// Использование функционала оплаты частями
  final bool? enableBnpl;
}

/// Конфигурация оплаты
class PayConfig {
  const PayConfig({
    required this.apiKey,
    required this.merchantLogin,
    required this.bankInvoiceId,
    required this.redirectUri,
    required this.orderNumber,
  });

  /// Ключ, выдаваемый по договору, либо создаваемый в личном кабинете
  final String apiKey;

  /// Логин, выдаваемый по договору, либо создаваемый в личном кабинете
  final String merchantLogin;

  /// Уникальный идентификатор заказа, сгенерированный Банком
  final String bankInvoiceId;

  /// Диплинк для перехода обратно в приложение после открытия Сбербанка
  final String redirectUri;

  /// Номер заказа
  final String orderNumber;
}

@HostApi()
abstract class SberPayApi {
  bool initSberPay(InitConfig config);

  bool isReadyForSPaySdk();

  @async
  SberPayApiPaymentStatus payWithBankInvoiceId(PayConfig config);
}
