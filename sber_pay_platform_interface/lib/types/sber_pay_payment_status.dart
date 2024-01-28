/// Статусы оплаты
enum SberPayPaymentStatus {
  /// Успешный результат
  success,

  /// Необходимо проверить статус оплаты
  processing,

  /// Пользователь отменил оплату
  cancel,

  /// Неизвестный тип
  unknown;
}