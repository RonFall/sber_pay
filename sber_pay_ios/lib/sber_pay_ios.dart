import 'package:flutter/foundation.dart';
import 'package:sber_pay_ios/src/messages.g.dart';
import 'package:sber_pay_platform_interface/sber_pay_platform_interface.dart';

class SberPayIOS extends SberPayPlatform {
  /// Creates a new plugin implementation instance.
  SberPayIOS({
    @visibleForTesting SberPayApi? api,
  }) : _api = api ?? SberPayApi();

  static void registerWith() {
    SberPayPlatform.instance = SberPayIOS();
  }

  final SberPayApi _api;

  @override
  Future<bool> initSberPay(SberPayInitConfig config) async {
    final envConfig = switch (config.env) {
      SberPayEnv.sandboxRealBankApp => SberPayApiEnv.sandboxRealBankApp,
      SberPayEnv.sandboxWithoutBankApp => SberPayApiEnv.sandboxWithoutBankApp,
      _ => SberPayApiEnv.prod,
    };
    final result = await _api.initSberPay(
      InitConfig(
        env: envConfig,
        enableBnpl: config.enableBnpl,
      ),
    );
    return result;
  }

  @override
  Future<bool> isReadyForSPaySdk() {
    return _api.isReadyForSPaySdk();
  }

  @override
  Future<SberPayPaymentStatus> payWithBankInvoiceId(
    SberPayPaymentConfig config,
  ) async {
    final result = await _api.payWithBankInvoiceId(
      PayConfig(
        apiKey: config.apiKey,
        merchantLogin: config.merchantLogin,
        bankInvoiceId: config.bankInvoiceId,
        redirectUri: config.redirectUri,
        orderNumber: config.orderNumber,
      ),
    );
    return switch (result) {
      SberPayApiPaymentStatus.success => SberPayPaymentStatus.success,
      SberPayApiPaymentStatus.processing => SberPayPaymentStatus.processing,
      SberPayApiPaymentStatus.cancel => SberPayPaymentStatus.cancel,
      _ => SberPayPaymentStatus.unknown
    };
  }
}
