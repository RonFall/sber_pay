import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sber_pay/sber_pay_button.dart';
import 'package:sber_pay/sber_pay.dart';
import 'package:sber_pay/sber_pay_env.dart';

/// Необходимо указать по данным из договора
const _apiKey = '';
const _merchantLogin = '';

/// Диплинк на переход в приложение
const _redirectUri = 'sbersdk://spay';

void main() => runApp(const SberPayExampleApp());

class SberPayExampleApp extends StatefulWidget {
  const SberPayExampleApp({super.key});

  @override
  State<SberPayExampleApp> createState() => _SberPayExampleAppState();
}

class _SberPayExampleAppState extends State<SberPayExampleApp> {
  late final TextEditingController _controller;
  late String _paymentStatus;
  late bool _isPluginLoading;
  late bool _isAppReadyForPay;
  late bool _isPluginInitialized;
  late SberPayEnv _selectedInitType;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _paymentStatus = '';
    _selectedInitType = SberPayEnv.sandboxWithoutBankApp;
    _isPluginLoading = false;
    _isAppReadyForPay = false;
    _isPluginInitialized = false;
    _readyForPay();
  }

  Future<void> _readyForPay() async {
    setState(() => _isPluginLoading = true);
    _isPluginInitialized = await SberPayPlugin.initSberPay(
      env: _selectedInitType.name,
      bnplPlan: true,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21A038)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SberPay plugin example'),
          backgroundColor: const Color(0xFF21A038),
          centerTitle: true,
        ),
        body: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _tableRowWrapper(
                          'Тип запуска',
                          Column(
                            children: [
                              ChoiceChip(
                                label: const Text('Прод'),
                                selected: _selectedInitType == SberPayEnv.prod,
                                onSelected: (_) {
                                  setState(() =>
                                      _selectedInitType = SberPayEnv.prod);
                                  _readyForPay();
                                },
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Песочница/Банк'),
                                selected: _selectedInitType ==
                                    SberPayEnv.sandboxRealBankApp,
                                onSelected: (_) {
                                  setState(() => _selectedInitType =
                                      SberPayEnv.sandboxRealBankApp);
                                  _readyForPay();
                                },
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Песочница'),
                                selected: _selectedInitType ==
                                    SberPayEnv.sandboxWithoutBankApp,
                                onSelected: (_) {
                                  setState(() => _selectedInitType =
                                      SberPayEnv.sandboxWithoutBankApp);
                                  _readyForPay();
                                },
                              ),
                            ],
                          ),
                        ),
                        _tableRowWrapper(
                          'Плагин проинициализирован',
                          Text(_isPluginLoading
                              ? 'Загрузка'
                              : _isPluginInitialized
                                  ? "ДА"
                                  : "НЕТ"),
                        ),
                        _tableRowWrapper(
                          'Оплата доступна',
                          Text(_isPluginLoading
                              ? 'Загрузка'
                              : _isAppReadyForPay
                                  ? "ДА"
                                  : "НЕТ"),
                        ),
                        _tableRowWrapper(
                          'Статус операции оплаты',
                          Text(
                            _paymentStatus.isEmpty
                                ? "Оплата не производилась"
                                : _paymentStatus,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Введите bankInvoiceID',
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
                              if (_apiKey.isEmpty || _merchantLogin.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Не заданы apiKey и/или merchantLogin',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
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
                                    apiKey: _apiKey,
                                    merchantLogin: _merchantLogin,
                                    bankInvoiceId: _controller.text,
                                    redirectUri: _redirectUri,
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
              ),
            );
          },
        ),
      ),
    );
  }

  TableRow _tableRowWrapper(String title, Widget secondChild) {
    return TableRow(
      children: [
        TableCell(child: Text(title, textAlign: TextAlign.center)),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(child: secondChild),
        ),
      ],
    );
  }
}
