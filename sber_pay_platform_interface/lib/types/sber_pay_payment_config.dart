/// Конфигурация оплаты
class SberPayPaymentConfig {
  const SberPayPaymentConfig({
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

  /// Диплинк для перехода обратно в приложение после открытия Сбербанка (только на iOS)
  final String redirectUri;

  /// Номер заказа
  final String orderNumber;
}
