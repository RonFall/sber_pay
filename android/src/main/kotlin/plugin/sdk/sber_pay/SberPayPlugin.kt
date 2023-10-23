package plugin.sdk.sber_pay

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import spay.sdk.SPaySdkApp
import spay.sdk.api.PaymentResult
import spay.sdk.api.SPayStage
import spay.sdk.view.SPayButton

/**
 * Плагин для оплаты с использованием SberPay. Для работы нужен установленный Сбер.
 */
class SberPayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private lateinit var binding: FlutterPluginBinding
  private lateinit var activity: Activity
  private lateinit var context: Context

  /** Кнопка для управления оплатой **/
  private lateinit var button: SPayButton

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sber_pay")
    binding = flutterPluginBinding
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      // Инициализация
      "init" -> {
        initialize(call, result)
      }
      // Проверка готовности к оплате
      "isReadyForSPaySdk" -> {
        /**
         * Метод для проверки готовности к оплате.
         * Зависит от переданного аргумента [env] при инициализации через метод [initialize]
         * (см. комментарий к методу). Запрос может выполняться долго.
         *
         * @return Если у пользователя нет установленного сбера в режимах
         * SPayStage.SandboxRealBankApp, SPayStage.prod - вернет false.
         */
        result.success(button.isReadyForSPaySdk())
      }
      // Оплата
      "payWithBankInvoiceId" -> {
        payWithBankInvoiceId(call, result)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  /**
   * Метод для оплаты, в аргументы которого обязательно необходимо передать:
   * @property apiKey ключ, выдаваемый по договору, либо создаваемый в личном кабинете;
   * @property merchantLogin логин, выдаваемый по договору, либо создаваемый в личном кабинете;
   * @property appPackage пакет вашего приложения;
   * @property language использовано по умолчанию "RU";
   * @property bankInvoiceId параметр, который получаем после запроса для регистрации заказа в
   * шлюзе Сбера.
   */
  private fun payWithBankInvoiceId(call: MethodCall, result: Result) {
    val args = call.arguments as Map<*, *>
    var responseSent = false // Флаг для отслеживания отправки ответа


    try {
      val apiKey = args["apiKey"] as String
      val merchantLogin = args["merchantLogin"] as String
      val bankInvoiceId = args["bankInvoiceId"] as String
      val appPackage = context.packageName
      val language = "RU"


      if (!responseSent) {
        button.payWithBankInvoiceId(apiKey, merchantLogin, bankInvoiceId, appPackage, language) { response ->
          when (response) {
            // Оплата не завершена
            is PaymentResult.Processing ->
              result.success("processing")
            // Оплата прошла успешно
            is PaymentResult.Success ->
              result.success("success")
            // Оплата прошла с ошибкой
            is PaymentResult.Error ->
              result.error("-", "MerchantError", response.merchantError?.description
                      ?: "Ошибка выполнения оплаты")
          }
          responseSent = true
        }
      }
    } catch (error: Exception) {
      result.error("-", error.localizedMessage, error.message)
    }
  }

  /**
   * Метод инициализации, выполняется перед стартом приложения.
   * [env], полученный из FLutter, Тесты со всеми типами [env] лучше всего проводить на реальном
   * устройстве. Он определяет тип запуска:
   *
   * @property SPayStage.SandboxRealBankApp устройство с установленным Сбером;
   * @property SPayStage.SandBoxWithoutBankApp устройство без Сбера;
   * @property SPayStage.prod устройство с установленным Сбером, работает с продовыми данными.
   */
  private fun initialize(call: MethodCall, result: Result) {
    val args = call.arguments as Map<*, *>
    val sPayStage = when (args["env"] as String) {
      "sandboxRealBankApp" -> SPayStage.SandboxRealBankApp
      "sandboxWithoutBankApp" -> SPayStage.SandBoxWithoutBankApp
      else -> {
        SPayStage.Prod
      }
    }

    try {
      // TODO(RonFall): Нужно получать нормальный API для ожидания инициализации, в текущей
      // версии SDK такого нет
      SPaySdkApp.getInstance().initialize(application = activity.application, stage = sPayStage, enableBnpl = true)
      result.success(true)
    } catch (e: Exception) {
      result.error("-", e.localizedMessage, e.message)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(activityBinding: ActivityPluginBinding) {
    activity = activityBinding.activity
    button = SPayButton(activity, null)
  }

  override fun onReattachedToActivityForConfigChanges(activityBinding: ActivityPluginBinding) {
    activity = activityBinding.activity
    button = SPayButton(activity, null)
  }

  override fun onDetachedFromActivity() {}

  override fun onDetachedFromActivityForConfigChanges() {}
}
