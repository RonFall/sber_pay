import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sber_pay/sber_pay_button.dart';
import 'package:sber_pay/sber_pay.dart';
import 'package:sber_pay/type_env.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TextEditingController _controller;
  late String _paymentStatus;
  late bool _isPluginLoading;
  late bool _isAppReadyForPay;
  late bool _isPluginInitialized;
  late TypeInitSberPay _selectedInitType;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _paymentStatus = '';
    _selectedInitType = TypeInitSberPay.sandboxWithoutBankApp;
    _isPluginLoading = false;
    _isAppReadyForPay = false;
    _isPluginInitialized = false;
    _readyForPay();
  }

  Future<void> _readyForPay() async {
    setState(() => _isPluginLoading = true);
    _isPluginInitialized = await SberPayPlugin.initSberPay(
      _selectedInitType.name,
    );
    if (mounted) setState(() {});

    _isAppReadyForPay = await SberPayPlugin.isReadyForSPaySdk();
    if (!_isAppReadyForPay) {
      _isAppReadyForPay = await SberPayPlugin.isReadyForSPaySdk();
    }
    if (mounted) setState(() => _isPluginLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _selectedInitTypeText() {
    switch (_selectedInitType) {
      case TypeInitSberPay.prod:
        return 'Прод';
      case TypeInitSberPay.sandboxRealBankApp:
        return 'Песочница/Банк';
      case TypeInitSberPay.sandboxWithoutBankApp:
        return 'Песочница';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Тип запуска:'),
                      Row(
                        children: [
                          Text(_selectedInitTypeText()),
                          PopupMenuButton<TypeInitSberPay>(
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                            ),
                            initialValue: _selectedInitType,
                            onSelected: (item) {
                              setState(() => _selectedInitType = item);
                              _readyForPay();
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<TypeInitSberPay>(
                                value: TypeInitSberPay.prod,
                                child: Text('Прод'),
                              ),
                              const PopupMenuItem<TypeInitSberPay>(
                                value: TypeInitSberPay.sandboxRealBankApp,
                                child: Text('Песочница/Банк'),
                              ),
                              const PopupMenuItem<TypeInitSberPay>(
                                value: TypeInitSberPay.sandboxWithoutBankApp,
                                child: Text('Песочница'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Плагин инициализирован: ${_isPluginLoading ? 'Загрузка' : _isPluginInitialized ? "ДА" : "НЕТ"}',
                  ),
                  Text(
                    'Оплата доступна: ${_isPluginLoading ? 'Загрузка' : _isAppReadyForPay ? "ДА" : "НЕТ"}',
                  ),
                  Text(
                    'Статус операции оплаты:  ${_paymentStatus.isEmpty ? "Оплата не производилась" : _paymentStatus}',
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'bankInvoiceID',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _paymentStatus = '');
                          },
                          child: const Icon(Icons.close, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isPluginLoading
                        ? Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF21A038),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : SberPayButton(
                            onPressed: () async {
                              if (_controller.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Введите bankInvoiceID'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                try {
                                  final result =
                                      await SberPayPlugin.payWithBankInvoiceId(
                                    apiKey: '-',
                                    merchantLogin: '-',
                                    bankInvoiceId: _controller.text,
                                    redirectUri: 'sbersdk://spay',
                                  );
                                  setState(() => _paymentStatus = result);
                                } on PlatformException catch (e) {
                                  setState(
                                    () => _paymentStatus = e.details ?? '',
                                  );
                                }
                              }
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
