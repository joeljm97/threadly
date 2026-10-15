import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0; // 0 = address, 1 = payment
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _line = TextEditingController();
  final _city = TextEditingController();
  String _payment = 'Cash on Delivery';

  static const _payments = {
    'Cash on Delivery': Icons.payments_outlined,
    'UPI': Icons.qr_code_2,
    'Credit / Debit Card': Icons.credit_card,
    'Net Banking': Icons.account_balance_outlined,
  };

  @override
  void dispose() {
    for (final c in [_name, _phone, _pin, _line, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _address => '${_name.text}, ${_line.text}, ${_city.text} - ${_pin.text}. Ph: ${_phone.text}';

  void _continue() {
    if (_step == 0) {
      if (_form.currentState!.validate()) setState(() => _step = 1);
      return;
    }
    final shop = context.read<ShopProvider>();
    final order = shop.placeOrder(address: _address, payment: _payment);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => _OrderSuccess(orderId: order.id, amount: order.amount)),
      (r) => r.isFirst,
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      );

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.light,
        appBar: AppBar(
          title: Text(_step == 0 ? 'ADDRESS' : 'PAYMENT',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        body: ListView(
          children: [
            _Stepper(step: _step),
            if (_step == 0)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(children: [
                    TextFormField(
                      controller: _name,
                      decoration: _dec('Name*'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      decoration: _dec('Mobile No*'),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          RegExp(r'^[6-9][0-9]{9}$').hasMatch(v!.trim()) ? null : 'Enter a valid 10-digit number',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pin,
                      decoration: _dec('Pincode*'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          RegExp(r'^[1-9][0-9]{5}$').hasMatch(v!.trim()) ? null : 'Enter a valid pincode',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _line,
                      decoration: _dec('Address (House No, Building, Street, Area)*'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _city,
                      decoration: _dec('City / District*'),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ]),
                ),
              )
            else ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Deliver to', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(_address, style: const TextStyle(color: AppColors.grey)),
                  TextButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('CHANGE', style: TextStyle(color: AppColors.primary)),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text('PAYMENT OPTIONS', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    ..._payments.entries.map((e) => RadioListTile<String>(
                          value: e.key,
                          groupValue: _payment,
                          activeColor: AppColors.primary,
                          secondary: Icon(e.value),
                          title: Text(e.key),
                          subtitle: e.key == 'Cash on Delivery'
                              ? const Text('Demo mode — no real payment is taken')
                              : null,
                          onChanged: (v) => setState(() => _payment = v!),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            PriceDetails(shop),
            const SizedBox(height: 16),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: shop.cartItems.isEmpty ? null : _continue,
              child: Text(_step == 0 ? 'CONTINUE' : 'PAY ${rupees(shop.payable)}'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int step;
  const _Stepper({required this.step});

  @override
  Widget build(BuildContext context) {
    Widget label(String t, bool active) => Text(t,
        style: TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.green : AppColors.grey));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        label('BAG', true),
        const Text('  - - - -  ', style: TextStyle(color: AppColors.grey)),
        label('ADDRESS', true),
        const Text('  - - - -  ', style: TextStyle(color: AppColors.grey)),
        label('PAYMENT', step == 1),
      ]),
    );
  }
}

class _OrderSuccess extends StatelessWidget {
  final String orderId;
  final int amount;
  const _OrderSuccess({required this.orderId, required this.amount});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 20),
                const Text('Order confirmed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Order #$orderId • ${rupees(amount)}', style: const TextStyle(color: AppColors.grey)),
                const SizedBox(height: 4),
                const Text('You can track it under Profile → Orders.',
                    style: TextStyle(color: AppColors.grey)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CONTINUE SHOPPING'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
}
