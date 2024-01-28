import 'package:sber_pay_platform_interface/sber_pay_platform_interface.dart';

/// Плагин для отображения нативной кнопки SberPay SDK
///
/// Все исключения (Exceptions) приходящие из методов этого класса должны
/// обрабатываться уровнем выше.
class SberPayPlugin {
  static SberPayPlatform get _platform => SberPayPlatform.instance;

  /// Инициализация SberPay SDK.
  ///
  /// Необходимо выполнить для начала работы с библиотекой.
  /// На платформе Android этот метод является асинхронным, однако у
  /// него нет API (коллбека) для выполнения кода после завершения
  /// инициализации.
  ///
  /// * [env] - среда запуска, которая определяется через [SberPayEnv].
  /// * [enableBnpl] - функционал оплаты частями
  static Future<bool> initSberPay({
    required SberPayEnv env,
    bool? enableBnpl,
  }) async =>
      _platform.initSberPay(
        SberPayInitConfig(
          env: env,
          enableBnpl: enableBnpl,
        ),
      );

  /// Метод для проверки готовности к оплате.
  ///
  /// Зависит от переданного аргумента *env* при инициализации через метод
  /// [initSberPay] (см. комментарий к методу).
  ///
  /// Метод инициализации синхронный, хотя в нем выполняется асинхронная
  /// операция, которая неизвестно когда выполнится. Поэтому сначала нужно
  /// вызвать [initSberPay], подождать, к примеру, секунды 2 и только потом
  /// обращаться к этому методу (см. пример в example/lib/main.dart).
  ///
  /// Если у пользователя нет установленного сбера в режимах
  /// [SberPayEnv.sandboxRealBankApp], [SberPayEnv.prod] - вернет false.
  static Future<bool> isReadyForSPaySdk() async =>
      _platform.isReadyForSPaySdk();

  /// Метод оплаты через SberPay SDK.
  /// * [apiKey] - ключ, выдаваемый по договору, либо создаваемый в личном
  /// кабинете;
  /// * [merchantLogin] - логин, выдаваемый по договору, либо создаваемый в
  /// личном кабинете;
  /// * [bankInvoiceId] - параметр, который получаем после запроса для
  /// регистрации заказа в шлюзе Сбера.
  /// * [redirectUri] - диплинк для перехода обратно в приложение после открытия
  /// Сбербанка (только на iOS).
  /// * [orderNumber] - номер заказа при регистрации в шлюзе
  /// Сбербанка (только на iOS).
  ///
  /// Возвращает статус оплаты [SberPayPaymentStatus]
  static Future<SberPayPaymentStatus> payWithBankInvoiceId({
    required String apiKey,
    required String merchantLogin,
    required String bankInvoiceId,
    required String redirectUri,
    required String orderNumber,
  }) async =>
      _platform.payWithBankInvoiceId(
        SberPayPaymentConfig(
          apiKey: apiKey,
          merchantLogin: merchantLogin,
          bankInvoiceId: bankInvoiceId,
          redirectUri: redirectUri,
          orderNumber: orderNumber,
        ),
      );
}
