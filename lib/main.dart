import 'package:flutter/material.dart';

void main() => runApp(const TipCalcApp());

//root set up materialapp with no debug 
class TipCalcApp extends StatelessWidget {
  const TipCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia'),
      home: const TipCalcScreen(),
    );
  }
}

// stateful bc we need to track user input and results
class TipCalcScreen extends StatefulWidget {
  const TipCalcScreen({super.key});

  @override
  State<TipCalcScreen> createState() => _TipCalcScreenState();
}

class _TipCalcScreenState extends State<TipCalcScreen> {
  // pastel colors to cycle through on tap
  static const List<Color> _bgColors = [
    Color(0xFFFFB3BA), // pink
    Color(0xFFFFD9A0), // orange
    Color(0xFFFFFFBC), // yellow
    Color(0xFFB5EAD7), // green
    Color(0xFFC7CEEA), // lavender
  ];

  //tracks which color we're on
  int _colorIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _billController = TextEditingController();
  final _peopleController = TextEditingController();
  //default tip starts at 18%
  double _tipPercent = 18;
  //null until user hits calculate
  String? _resultText;

  //getter for current bg color
  Color get _bg => _bgColors[_colorIndex];

  //picks black or white text based on contrast so it's always readable
  Color get _fg => _bg.computeLuminance() > 0.4 ? Colors.black : Colors.white;

  //wraps around when we hit the end of the list
  void _cycleColor() => setState(() => _colorIndex = (_colorIndex + 1) % _bgColors.length);

  void _calculate() {
    //dismiss keyboard first
    FocusScope.of(context).unfocus();
    // exit if any field fails validation
    if (!_formKey.currentState!.validate()) return;

    final bill = double.parse(_billController.text.trim());
    final people = int.parse(_peopleController.text.trim());
    final tip = bill * (_tipPercent / 100);
    final total = bill + tip;

    //update result string triggers rebuild to show result card
    setState(() {
      _resultText =
          'Tip:         \$${tip.toStringAsFixed(2)}\n'
          'Total:      \$${total.toStringAsFixed(2)}\n'
          'Per person: \$${(total / people).toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    //gesture detector wraps everything so tapping bg cycles colors
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _cycleColor,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          //matches backround so it blends in
          backgroundColor: _bg,
          elevation: 0,
          title: Text(
            'Tip Calculator',
            style: TextStyle(color: _fg, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //hint text at top so user knows they can tap to change color
                  Text(
                    'tap empty areas to cycle colors',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _fg.withOpacity(0.5), fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  //bill input with decimals
                  _label('Bill Amount (\$)'),
                  const SizedBox(height: 6),
                  _field(
                    controller: _billController,
                    hint: 'ex. 45.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      final n = double.tryParse(val?.trim() ?? '');
                      if (n == null) return 'enter a valid number';
                      if (n <= 0) return 'bill must be greater than \$0';
                      if (n > 100000) return 'max \$100,000';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  //slider for tip % 0–30 in whole numbers
                  _label('Tip: ${_tipPercent.round()}%'),
                  SliderTheme(
                    //tints slider 
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _fg.withOpacity(0.8),
                      inactiveTrackColor: _fg.withOpacity(0.2),
                      thumbColor: _fg,
                      overlayColor: _fg.withOpacity(0.1),
                    ),
                    child: Slider(
                      value: _tipPercent,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      label: '${_tipPercent.round()}%',
                      onChanged: (val) => setState(() => _tipPercent = val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //how many people splitting the bill
                  _label('Split Between (people)'),
                  const SizedBox(height: 6),
                  _field(
                    controller: _peopleController,
                    hint: 'ex. 3',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      final n = int.tryParse(val?.trim() ?? '');
                      if (n == null) return 'enter a whole number';
                      if (n < 1) return 'at least 1 person required';
                      if (n > 500) return 'max 500 people';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  //calculate button with swapped colors so it is easier to read
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fg,
                      foregroundColor: _bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Calculate', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),

                  //result card only shows after a successful calculation
                  if (_resultText != null) ...[
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      //transparent box so it floats above backround
                      decoration: BoxDecoration(
                        color: _fg.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _fg.withOpacity(0.25)),
                      ),
                      child: Text(
                        _resultText!,
                        style: TextStyle(
                          color: _fg,
                          fontSize: 18,
                          height: 1.8,
                          //monospace for columnsto be aligned
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //reusable styled label above each input
  Widget _label(String text) => Text(
        text,
        style: TextStyle(color: _fg, fontWeight: FontWeight.w600, fontSize: 15),
      );

  //reusable text field w/ consistent theming + border states
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: _fg),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _fg.withOpacity(0.4)),
        filled: true,
        fillColor: _fg.withOpacity(0.1),
        errorStyle: TextStyle(color: _fg, fontWeight: FontWeight.w600),
        //slightly transparent border when idle
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fg.withOpacity(0.3)),
        ),
        //solid border thicker when user clicks on it
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fg, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fg.withOpacity(0.8), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _fg, width: 2),
        ),
      ),
    );
  }

  //dispose controllers when widget leaves tree
  @override
  void dispose() {
    _billController.dispose();
    _peopleController.dispose();
    super.dispose();
  }
}