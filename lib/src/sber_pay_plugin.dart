import 'package:flutter/services.dart';
import 'sber_pay_env.dart';
import 'sber_pay_payment_status.dart';

/// Плагин для отображения нативной кнопки SberPay SDK
///
/// Все исключения (Exceptions) приходящие из методов этого класса должны
/// обрабатываться уровнем выше.
class SberPayPlugin {
  static const methodChannel = MethodChannel('sber_pay');

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
    required String env,
    bool? enableBnpl,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('init', {
      'env': env,
      if (enableBnpl != null) 'enableBnpl': enableBnpl,
    });
    return result ?? false;
  }

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
  static Future<bool> isReadyForSPaySdk() async {
    final result = await methodChannel.invokeMethod<bool>('isReadyForSPaySdk');
    if (result == null || result == false) {
      await Future.delayed(
        const Duration(seconds: 2),
        () async {
          return await methodChannel.invokeMethod<bool>('isReadyForSPaySdk');
        },
      );
    }
    return result ?? false;
  }

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
  static Future<SberPayPaymentStatus> payWithBankInvoiceId({
    required String apiKey,
    required String merchantLogin,
    required String bankInvoiceId,
    required String redirectUri,
  }) async {
    final result = await methodChannel.invokeMethod<String>(
      'payWithBankInvoiceId',
      {
        'apiKey': apiKey,
        'merchantLogin': merchantLogin,
        'bankInvoiceId': bankInvoiceId,
        'redirectUri': redirectUri,
      },
    );
    return SberPayPaymentStatus.fromString(result);
  }
}
