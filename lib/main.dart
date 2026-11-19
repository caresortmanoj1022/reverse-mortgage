import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const ReverseDemoApp());

const navy = Color(0xFF12395B);
const blue = Color(0xFF1473B8);
const red = Color(0xFF9D2036);
const ink = Color(0xFF192B3A);
const muted = Color(0xFF6D7C89);
const canvas = Color(0xFFF5F7F9);

class ReverseDemoApp extends StatelessWidget {
  const ReverseDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'JERRY™ Reverse Mortgage Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: canvas,
          colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
          fontFamily: 'Roboto',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: Color(0xFF9AA7B1)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE3E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE3E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: blue, width: 1.6)),
          ),
        ),
        home: const CalculatorFlow(),
      );
}

class CalculatorFlow extends StatefulWidget {
  const CalculatorFlow({super.key});

  @override
  State<CalculatorFlow> createState() => _CalculatorFlowState();
}

class _CalculatorFlowState extends State<CalculatorFlow> {
  int step = 0;
  bool purchase = false;
  bool spouse = false;
  String birthYear = '1960';
  final zip = TextEditingController();
  final value = TextEditingController();
  final mortgage = TextEditingController(text: '0');
  final address = TextEditingController();

  @override
  void dispose() {
    zip.dispose(); value.dispose(); mortgage.dispose(); address.dispose();
    super.dispose();
  }

  // Fixed sample figures keep this a visual, click-through mockup rather than
  // a working reverse mortgage calculator.
  double get homeValue => 450000;
  double get mortgageBalance => 45000;
  double get estimatedPrincipal => 176000;
  double get estimatedNet => 121500;

  void next() {
    FocusScope.of(context).unfocus();
    setState(() => step = (step + 1).clamp(0, 2));
  }

  void back() => setState(() => step = (step - 1).clamp(0, 2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _topBar(),
          Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: _screen(key: ValueKey(step)))),
        ]),
      ),
    );
  }

  Widget _topBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE8EDF1)))),
        child: Column(children: [
          Row(children: [
            if (step > 0) IconButton(onPressed: back, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: navy, visualDensity: VisualDensity.compact)
            else const SizedBox(width: 40),
            Expanded(child: Center(child: Image.asset('assets/spectrum-logo.png', height: 42, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('SPECTRUM ONE', style: TextStyle(color: red, fontWeight: FontWeight.w800, letterSpacing: 1.3))))),
            const SizedBox(width: 40),
          ]),
          const SizedBox(height: 11),
          Row(children: List.generate(3, (i) => Expanded(child: Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : 7),
            child: Column(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: step >= i ? 1 : 0, minHeight: 4, backgroundColor: const Color(0xFFE6EBEF), color: blue)),
              const SizedBox(height: 6),
              Text(['Your goals', 'Your home', 'Your estimate'][i], style: TextStyle(fontSize: 10, color: step == i ? navy : muted, fontWeight: step == i ? FontWeight.w700 : FontWeight.w400)),
            ]),
          )))),
        ]),
      );

  Widget _screen({required Key key}) => SingleChildScrollView(
        key: key,
        padding: const EdgeInsets.fromLTRB(22, 23, 22, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (step == 0) _borrowerScreen(),
          if (step == 1) _homeScreen(),
          if (step == 2) _resultsScreen(),
          const SizedBox(height: 24),
          if (step < 2) _primaryButton(step == 0 ? 'Continue' : 'See my estimate', next),
          const SizedBox(height: 22),
          _trustLine(),
        ]),
      );

  Widget _borrowerScreen() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _jerryWelcome(),
        const SizedBox(height: 24),
        const Text('Let’s start with your goals', style: TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 8),
        const Text('A few details help us shape a more useful estimate.', style: TextStyle(fontSize: 15, color: muted, height: 1.45)),
        const SizedBox(height: 23),
        const _FieldLabel('I need a reverse mortgage for'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _choice('Current home', !purchase, () => setState(() => purchase = false))),
          const SizedBox(width: 10),
          Expanded(child: _choice('New home purchase', purchase, () => setState(() => purchase = true))),
        ]),
        const SizedBox(height: 23),
        const _FieldLabel('Your date of birth'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: birthYear, decoration: const InputDecoration(), items: ['Year', ...List.generate(61, (i) => '${DateTime.now().year - 62 - i}')].map((y) => DropdownMenuItem(value: y, child: Text(y == 'Year' ? 'Choose birth year' : y))).toList(), onChanged: (v) => setState(() => birthYear = v ?? 'Year')),
        const SizedBox(height: 15),
        InkWell(onTap: () => setState(() => spouse = !spouse), child: Row(children: [Checkbox(value: spouse, onChanged: (v) => setState(() => spouse = v ?? false), activeColor: blue), const Expanded(child: Text('I have a spouse or co-borrower', style: TextStyle(color: ink, fontSize: 14)))])),
        if (spouse) ...[
          const SizedBox(height: 8), const _FieldLabel('Spouse or co-borrower birth year'), const SizedBox(height: 9),
          DropdownButtonFormField<String>(value: null, hint: const Text('Choose birth year'), decoration: const InputDecoration(), items: List.generate(61, (i) => '${DateTime.now().year - 62 - i}').map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (_) {}),
        ],
      ]);

  Widget _homeScreen() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _jerryWelcome(), const SizedBox(height: 24),
        const Text('Tell us about your home', style: TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 8),
        const Text('We’ll use these details to create a sample estimate.', style: TextStyle(fontSize: 15, color: muted, height: 1.45)),
        const SizedBox(height: 24),
        const _FieldLabel('Property ZIP code'), const SizedBox(height: 8),
        TextField(controller: zip, keyboardType: TextInputType.number, maxLength: 5, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(hintText: 'e.g. 90210', counterText: '')),
        const SizedBox(height: 18),
        const _FieldLabel('Estimated home value'), const SizedBox(height: 8),
        TextField(controller: value, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(prefixText: r'$ ', hintText: '450,000')),
        const SizedBox(height: 18),
        const _FieldLabel('Existing mortgage balance'), const SizedBox(height: 8),
        TextField(controller: mortgage, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(prefixText: r'$ ', hintText: '0')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEAF3FA), borderRadius: BorderRadius.circular(14)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline_rounded, color: blue, size: 19), SizedBox(width: 10), Expanded(child: Text('No Social Security number, credit pull, or personal contact details required.', style: TextStyle(color: navy, height: 1.4, fontSize: 13)))])),
      ]);

  Widget _resultsScreen() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _jerryWelcome(), const SizedBox(height: 23),
        const Text('Your estimate', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 7),
        const Text('A starting point for exploring your options.', style: TextStyle(color: muted, fontSize: 15)),
        const SizedBox(height: 20),
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF173D5F), Color(0xFF206FA8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22), boxShadow: const [BoxShadow(color: Color(0x2212395B), blurRadius: 20, offset: Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ESTIMATED FUNDS AFTER PAYOFF', style: TextStyle(color: Color(0xFFD9E9F5), fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8), Text(_money(estimatedNet), style: const TextStyle(color: Colors.white, fontSize: 39, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 12), const Text('Illustrative demo estimate', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ])),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(height: 145, width: double.infinity, child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/jerry-scene.jpg', fit: BoxFit.cover, alignment: const Alignment(0, -.25)),
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [navy.withOpacity(.72), Colors.transparent], stops: const [0, .82]))),
          const Positioned(left: 15, bottom: 13, child: Text('Jerry is here to help you explore.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
        ]))),
        const SizedBox(height: 18),
        _resultRow(Icons.home_outlined, 'Estimated home value', _money(homeValue)),
        _resultRow(Icons.account_balance_outlined, 'Estimated loan proceeds', _money(estimatedPrincipal)),
        _resultRow(Icons.payments_outlined, 'Mortgage payoff', '− ${_money(mortgageBalance)}'),
        _resultRow(Icons.receipt_long_outlined, 'Sample fees', '− \$9,500'),
        const SizedBox(height: 13),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF5E8), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFE2B8))), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: Color(0xFFB56B12), size: 20), SizedBox(width: 10), Expanded(child: Text('This demo uses simplified sample math. Actual proceeds depend on current rates, age, property, program, and lender fees.', style: TextStyle(color: Color(0xFF704B21), fontSize: 13, height: 1.45)))])),
        const SizedBox(height: 18),
        if (estimatedNet <= 0) Text('Based on these sample inputs, your existing mortgage may be higher than the estimated available proceeds.', style: TextStyle(color: red, fontSize: 14, height: 1.45, fontWeight: FontWeight.w600))
        else const Text('A reverse mortgage may help pay off an existing mortgage and remove required monthly mortgage payments while you meet loan obligations.', style: TextStyle(color: ink, fontSize: 14, height: 1.5)),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () => setState(() => step = 1), icon: const Icon(Icons.tune_rounded), label: const Text('Adjust my details'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), foregroundColor: navy, side: const BorderSide(color: Color(0xFFD5DEE5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      ]);

  Widget _jerryWelcome() => Container(
        padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5EBEF))),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/jerry-avatar.png', width: 62, height: 62, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _JerryPlaceholder())),
          const SizedBox(width: 13),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Hi, I’m Jerry!', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16)), SizedBox(height: 3), Text('Your reverse mortgage guide', style: TextStyle(color: muted, fontSize: 12)), SizedBox(height: 7), Text('Let’s find a comfortable place to start.', style: TextStyle(color: ink, fontSize: 13))])),
          const Icon(Icons.verified_user_outlined, color: Color(0xFF5C9A76), size: 20),
        ]),
      );

  Widget _choice(String label, bool selected, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: AnimatedContainer(duration: const Duration(milliseconds: 160), height: 62, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: selected ? const Color(0xFFEAF3FA) : Colors.white, border: Border.all(color: selected ? blue : const Color(0xFFDCE3E8), width: selected ? 1.6 : 1), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? blue : muted, size: 19), const SizedBox(width: 8), Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: selected ? navy : ink, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)))])));

  Widget _primaryButton(String label, VoidCallback onPressed) => SizedBox(width: double.infinity, height: 58, child: FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(width: 9), const Icon(Icons.arrow_forward_rounded, size: 19)])));

  Widget _trustLine() => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shield_outlined, size: 15, color: muted), SizedBox(width: 7), Flexible(child: Text('No credit check  ·  No commitment  ·  Your info stays private', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: muted)))]);

  Widget _resultRow(IconData icon, String label, String amount) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [Icon(icon, size: 18, color: blue), const SizedBox(width: 10), Expanded(child: Text(label, style: const TextStyle(color: muted, fontSize: 14))), Text(amount, style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w700))]));

  String _money(double n) => '\$${n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 14, color: navy, fontWeight: FontWeight.w700));
}

class _JerryPlaceholder extends StatelessWidget {
  const _JerryPlaceholder();
  @override
  Widget build(BuildContext context) => Container(width: 62, height: 62, color: const Color(0xFFEAF3FA), child: const Icon(Icons.pets_rounded, color: blue, size: 32));
}
