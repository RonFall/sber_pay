import Flutter
import UIKit
import SPaySdk

public class SberPayPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sber_pay", binaryMessenger: registrar.messenger())
        let instance = SberPayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        /// Создание [addApplicationDelegate] для перехода по диплинку обратно в приложение
        registrar.addApplicationDelegate(instance)
    }


    public func application(_ app: UIApplication,open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        /// Если при открытии приложения с диплинком если он содержит хост "spay", то такой диплинк
        /// попадает в нативный плагин. Таким образом работает возврат в приложение и получение данных нативным
        /// SDK от приложения Сбербанк онлайн/СБОЛ
        if  url.host == "spay" {
            SPay.getAuthURL(url)
        }

        return true
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            /// Инициализация
        case "init":
            initialize(call, result:result)
            /// Проверка готовности к оплате
        case "isReadyForSPaySdk":
            /**
             Метод для проверки готовности к оплате.
             Зависит от переданного аргумента [env] при инициализации через метод [initialize]
             (см. комментарий к методу). Запрос может выполняться долго.

             - Returns Если у пользователя нет установленного сбера в режимах SEnvironment.sandboxRealBankApp,
             SEnvironment.prod - вернет false.
             */
            result(SPay.isReadyForSPay)
            // Оплата
        case "payWithBankInvoiceId":
            payWithBankInvoiceId(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /**
     Метод для оплаты, в аргументы которого обязательно необходимо передать:
     - Parameter apiKey ключ, выдаваемый по договору, либо создаваемый в личном кабинете;
     - Parameter merchantLogin логин, выдаваемый по договору, либо создаваемый в личном кабинете;
     - Parameter bankInvoiceId параметр, который получаем после запроса для регистрации заказа в
     шлюзе Сбера.
     - Parameter redirectUri диплинк обратно в приложение после перехода в Сбербанк
     */
    private func payWithBankInvoiceId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String,
              let merchantLogin = args["merchantLogin"] as? String,
              let bankInvoiceId = args["bankInvoiceId"] as? String,
              let redirectUri = args["redirectUri"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        if bankInvoiceId.count != 32 {
            result(FlutterError(code: "-", message: "MerchantError", details: "Длина bankInvoiceId должна быть 32 символа"))
        } else {
            let request = SBankInvoicePaymentRequest(
                merchantLogin: merchantLogin,
                bankInvoiceId: bankInvoiceId,
                language: "RU",
                redirectUri: redirectUri,
                apiKey: apiKey)
            if let topController = getTopViewController() {
                SPay.payWithBankInvoiceId(with: topController, paymentRequest: request) { state, info  in
                    switch state {
                    case .success:
                        result("success")
                    case .waiting:
                        result("processing")
                    case .cancel:
                        result("cancel")
                    case .error:
                        result(FlutterError(code: "-", message: "Ошибка оплаты", details: info))
                    @unknown default:
                        result(FlutterError(code: "-", message: "Неопределенная ошибка", details: info))
                    }
                }
            } else {
                result(FlutterError(code: "PluginError", message: "SberPay: Failed to implement controller", details: nil))
            }
        }
    }

    /**
     Метод инициализации, выполняется перед стартом приложения.
     [env], полученный из FLutter, Тесты со всеми типами [env] лучше всего проводить на реальном устройстве. Он
     определяет тип запуска:

     - Parameter SEnvironment.sandboxRealBankApp устройство с установленным Сбером;
     - Parameter SEnvironment.sandboxWithoutBankApp устройство без Сбера;
     - Parameter SEnvironment.prod устройство с установленным Сбером, работает с продовыми данными.
     - Parameter enableBnpl Функционал Оплата частями
     */
    private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let env = args["env"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let enableBnpl = args["enableBnpl"] as? Bool ?? false

        var sPayStage: SEnvironment = .prod
        switch env {
        case "sandboxRealBankApp":
            sPayStage = .sandboxRealBankApp
        case "sandboxWithoutBankApp":
            sPayStage = .sandboxWithoutBankApp
        default:
            break
        }

        SPay.setup(bnplPlan: enableBnpl, environment: sPayStage)
        result(true)
    }

    private func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }

        return nil
    }
}