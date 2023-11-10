import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sber_pay_platform_interface/sber_pay_platform_interface.dart';

class MethodChannelSberPay extends SberPayPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('sber_pay');

  @override
  Future<bool?> initSberPay({required String env, bool? enableBnpl}) {
    return methodChannel.invokeMethod<bool>(
      'init',
      {'env': env, 'enableBnpl': enableBnpl},
    );
  }

  @override
  Future<bool?> isReadyForSPaySdk() {
    return methodChannel.invokeMethod<bool>('isReadyForSPaySdk');
  }

  @override
  Future<String?> payWithBankInvoiceId({
    required String apiKey,
    required String merchantLogin,
    required String bankInvoiceId,
    required String redirectUri,
  }) {
    return methodChannel.invokeMethod<String>(
      'payWithBankInvoiceId',
      {
        'apiKey': apiKey,
        'merchantLogin': merchantLogin,
        'bankInvoiceId': bankInvoiceId,
        'redirectUri': redirectUri,
      },
    );
  }
}
