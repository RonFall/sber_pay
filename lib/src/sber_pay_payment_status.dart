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

  static fromString(String? value) {
    switch (value) {
      case "success":
        return SberPayPaymentStatus.success;
      case "processing":
        return SberPayPaymentStatus.processing;
      case "cancel":
        return SberPayPaymentStatus.cancel;
      default:
        return SberPayPaymentStatus.unknown;
    }
  }
}