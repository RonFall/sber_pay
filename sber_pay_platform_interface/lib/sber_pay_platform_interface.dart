import 'package:sber_pay_platform_interface/src/method_channel_sber_pay.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class SberPayPlatform extends PlatformInterface {
  SberPayPlatform() : super(token: _token);

  static final Object _token = Object();

  static SberPayPlatform _instance = MethodChannelSberPay();

  static SberPayPlatform get instance => _instance;

  static set instance(SberPayPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Инициализация SberPay SDK.
  ///
  /// Необходимо выполнить для начала работы с библиотекой.
  /// На платформе Android этот метод является асинхронным, однако у
  /// него нет API (коллбека) для выполнения кода после завершения
  /// инициализации.
  ///
  /// * [env] - среда запуска, которая определяется через [SberPayEnv].
  /// * [enableBnpl] - функционал оплаты частями
  Future<bool?> initSberPay({required String env, bool? enableBnpl});

  /// Метод для проверки готовности к оплате.
  ///
  /// Зависит от переданного аргумента [env] при инициализации через метод
  /// [initSberPay] (см. комментарий к методу).
  ///
  /// Запрос может выполняться долго, поэтому здесь стоит искусственная
  /// задержка, чтобы дождаться инициализации SDK.
  ///
  /// Если у пользователя нет установленного сбера в режимах
  /// [SberPayEnv.sandboxRealBankApp], [SberPayEnv.prod] - вернет false.
  Future<bool?> isReadyForSPaySdk();

  /// Метод оплаты через SberPay SDK.
  /// * [apiKey] - ключ, выдаваемый по договору, либо создаваемый в личном
  /// кабинете;
  /// * [merchantLogin] - логин, выдаваемый по договору, либо создаваемый в
  /// личном кабинете;
  /// * [bankInvoiceId] - параметр, который получаем после запроса для
  /// регистрации заказа в шлюзе Сбера.
  /// * [redirectUri] - диплинк для перехода обратно в приложение после открытия
  /// Сбербанка (только на iOS).
  ///
  /// Возвращает статус оплаты [SberPayPaymentStatus]
  Future<String?> payWithBankInvoiceId({
    required String apiKey,
    required String merchantLogin,
    required String bankInvoiceId,
    required String redirectUri,
  });
}
