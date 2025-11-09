import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tri-Lingual Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _currentOperand = '0';
  String _previousOperand = '';
  String _operation = '';
  String _currentLanguage = 'bn'; // Default language is Bengali

  final Map<String, Map<String, dynamic>> _languages = {
    'bn': {
      'numbers': ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'],
      'operators': {
        'add': '+',
        'subtract': '-',
        'multiply': '×',
        'divide': '÷',
        'percent': '%',
        'equals': '=',
        'decimal': '.'
      },
      'buttons': {
        'clear': 'C',
        'allClear': 'AC'
      },
      'developerCredit': 'ডেভেলপড বাই আতাউর রহমান রানা'
    },
    'en': {
      'numbers': ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      'operators': {
        'add': '+',
        'subtract': '-',
        'multiply': '×',
        'divide': '÷',
        'percent': '%',
        'equals': '=',
        'decimal': '.'
      },
      'buttons': {
        'clear': 'C',
        'allClear': 'AC'
      },
      'developerCredit': 'Developed by Ataur Rahman Rana'
    },
    'ar': {
      'numbers': ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'],
      'operators': {
        'add': '+',
        'subtract': '-',
        'multiply': '×',
        'divide': '÷',
        'percent': '%',
        'equals': '=',
        'decimal': '.'
      },
      'buttons': {
        'clear': 'C',
        'allClear': 'AC'
      },
      'developerCredit': 'طورت بواسطة عطاء الرحمن رانا'
    }
  };

  // Convert English numerals to current language numerals
  String _convertToLocalizedNumbers(String input) {
    if (_currentLanguage == 'en') return input;
    final Map<String, String> numMap = {};
    for (int i = 0; i < 10; i++) {
      numMap[i.toString()] = _languages[_currentLanguage]!['numbers'][i];
    }
    return input.replaceAllMapped(RegExp(r'[0-9]'), (match) => numMap[match.group(0)]!);
  }

  // Convert localized numerals to English numerals for computation
  String _convertToEnglishNumbers(String input) {
    if (_currentLanguage == 'en') return input;
    final Map<String, String> numMap = {};
    for (int i = 0; i < 10; i++) {
      numMap[_languages[_currentLanguage]!['numbers'][i]] = i.toString();
    }
    String result = input;
    numMap.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  void _appendNumber(String number) {
    setState(() {
      if (number == '.' && _currentOperand.contains('.')) return;

      if (_currentOperand == '0' && number != '.') {
        _currentOperand = number;
      } else {
        _currentOperand += number;
      }
    });
  }

  void _chooseOperation(String action) {
    setState(() {
      if (_currentOperand == '') return;

      if (_previousOperand != '') {
        _compute();
      }

      _operation = action;
      _previousOperand = _currentOperand;
      _currentOperand = '';
    });
  }

  void _compute() {
    setState(() {
      if (_previousOperand.isEmpty || _currentOperand.isEmpty || _operation.isEmpty) return;

      try {
        String expressionString = _convertToEnglishNumbers(_previousOperand) +
            _getEnglishOperator(_operation) +
            _convertToEnglishNumbers(_currentOperand);

        Parser p = Parser();
        Expression exp = p.parse(expressionString);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);

        _currentOperand = eval.toString();
        // Remove trailing .0 if it's an integer
        if (_currentOperand.endsWith('.0')) {
          _currentOperand = _currentOperand.substring(0, _currentOperand.length - 2);
        }

      } catch (e) {
        _currentOperand = 'Error'; // Handle calculation errors
      }

      _operation = '';
      _previousOperand = '';
    });
  }

  String _getEnglishOperator(String op) {
    switch (op) {
      case 'add':
        return '+';
      case 'subtract':
        return '-';
      case 'multiply':
        return '*';
      case 'divide':
        return '/';
      case 'percent':
        return '%'; // Note: Dart's math_expressions doesn't directly support modulo for floating point numbers like this. You might need custom logic for advanced percentage calculations.
      default:
        return '';
    }
  }

  void _clear() {
    setState(() {
      if (_currentOperand.length > 1) {
        _currentOperand = _currentOperand.substring(0, _currentOperand.length - 1);
      } else {
        _currentOperand = '0';
      }
    });
  }

  void _allClear() {
    setState(() {
      _currentOperand = '0';
      _previousOperand = '';
      _operation = '';
    });
  }

  void _changeLanguage(String lang) {
    setState(() {
      _currentLanguage = lang;
      // Convert current display if needed after language change
      _currentOperand = _convertToLocalizedNumbers(_convertToEnglishNumbers(_currentOperand));
      _previousOperand = _convertToLocalizedNumbers(_convertToEnglishNumbers(_previousOperand));
    });
  }

  Widget _buildButton(String text, {Color? backgroundColor, Color? textColor, int flex = 1, String? action, String? number}) {
    Color defaultBg = Colors.white.withOpacity(0.9);
    Color defaultText = Colors.black;

    if (action == 'all-clear' || action == 'clear') {
      defaultBg = const Color(0xFFe67e22); // Orange
      defaultText = Colors.white;
    } else if (action == 'equals') {
      defaultBg = const Color(0xFFe74c3c); // Red
      defaultText = Colors.white;
    } else if (action == 'add' || action == 'subtract' || action == 'multiply' || action == 'divide' || action == 'percent') {
      defaultBg = const Color(0xFFF8F9FA).withOpacity(0.95);
      defaultText = const Color(0xFFe74c3c);
    }

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(1),
        child: ElevatedButton(
          onPressed: () {
            if (number != null) {
              _appendNumber(number);
            } else if (action == 'all-clear') {
              _allClear();
            } else if (action == 'clear') {
              _clear();
            } else if (action == 'equals') {
              _compute();
            } else if (action != null) {
              _chooseOperation(action);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? defaultBg,
            foregroundColor: textColor ?? defaultText,
            padding: const EdgeInsets.symmetric(vertical: 22),
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // No border radius for buttons
            elevation: 0,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguageData = _languages[_currentLanguage]!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language Selector
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      _buildLanguageButton('বাংলা', 'bn'),
                      _buildLanguageButton('English', 'en'),
                      _buildLanguageButton('العربية', 'ar'),
                    ],
                  ),
                ),
                // Display
                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  constraints: const BoxConstraints(minHeight: 140),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _previousOperand.isNotEmpty && _operation.isNotEmpty
                            ? '${_convertToLocalizedNumbers(_previousOperand)} ${currentLanguageData['operators'][_operation]}'
                            : '',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          _convertToLocalizedNumbers(_currentOperand),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black38,
                                  offset: Offset(0, 2.0),
                                ),
                              ]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Buttons
                Container(
                  color: Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildButton(currentLanguageData['buttons']['allClear'], action: 'all-clear'),
                          _buildButton(currentLanguageData['buttons']['clear'], action: 'clear'),
                          _buildButton(currentLanguageData['operators']['percent'], action: 'percent'),
                          _buildButton(currentLanguageData['operators']['divide'], action: 'divide'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton(currentLanguageData['numbers'][7], number: '7'),
                          _buildButton(currentLanguageData['numbers'][8], number: '8'),
                          _buildButton(currentLanguageData['numbers'][9], number: '9'),
                          _buildButton(currentLanguageData['operators']['multiply'], action: 'multiply'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton(currentLanguageData['numbers'][4], number: '4'),
                          _buildButton(currentLanguageData['numbers'][5], number: '5'),
                          _buildButton(currentLanguageData['numbers'][6], number: '6'),
                          _buildButton(currentLanguageData['operators']['subtract'], action: 'subtract'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton(currentLanguageData['numbers'][1], number: '1'),
                          _buildButton(currentLanguageData['numbers'][2], number: '2'),
                          _buildButton(currentLanguageData['numbers'][3], number: '3'),
                          _buildButton(currentLanguageData['operators']['add'], action: 'add'),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton(currentLanguageData['numbers'][0], number: '0', flex: 2),
                          _buildButton(currentLanguageData['operators']['decimal'], number: '.'),
                          _buildButton(currentLanguageData['operators']['equals'], action: 'equals'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Developer Credit
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF34495e), Color(0xFF2c3e50)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                  ),
                  child: Text(
                    currentLanguageData['developerCredit'],
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String text, String langCode) {
    bool isActive = _currentLanguage == langCode;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextButton(
          onPressed: () => _changeLanguage(langCode),
          style: TextButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFF3498db).withOpacity(0.8) : Colors.transparent,
            foregroundColor: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
