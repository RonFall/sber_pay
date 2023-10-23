import Flutter
import UIKit
import SPaySdk

public class SberPayPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sber_pay", binaryMessenger: registrar.messenger())
        let instance = SberPayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }


    public func application(_ app: UIApplication,open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Если диплинк содержит хост "spay", тогда происходит редирект с Сбербанка обратно в приложение
        if  url.host == "spay" {
            SPay.getAuthURL(url)
        }

        return true
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            initialize(call, result:result)
        case "isReadyForSPaySdk":
            result(SPay.isReadyForSPay)
        case "payWithBankInvoiceId":
            payWithBankInvoiceId(call, result:result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func payWithBankInvoiceId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        let apiKey = args["apiKey"] as! String
        let merchantLogin = args["merchantLogin"] as! String
        let bankInvoiceId = args["bankInvoiceId"] as! String
        let redirectUri = args["redirectUri"] as! String

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

    private func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any?]
        var sPayStage =  SEnvironment.prod
        if args["env"] as! String == "sandboxRealBankApp" {
            sPayStage = SEnvironment.sandboxRealBankApp
        } else if args["env"] as! String == "sandboxWithoutBankApp" {
            sPayStage = SEnvironment.sandboxWithoutBankApp
        }
        SPay.setup(bnplPlan: true, environment: sPayStage)
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
