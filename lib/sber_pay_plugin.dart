import 'package:flutter/services.dart';

class SberPayPlugin {
  static const methodChannel = MethodChannel('sber_pay');

  static Future<bool> initSberPay(String env) async {
    final result = await methodChannel.invokeMethod<bool>('init', {'env': env});
    return result ?? false;
  }

  static Future<String> payWithBankInvoiceId({
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
    return result ?? "Ошибка выполнения оплаты";
  }

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
}
