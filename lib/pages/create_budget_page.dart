import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/components/alert_slider_thumb.dart';
import 'package:project_mobile/components/alert_slider_track.dart';
import 'package:project_mobile/services/api_service.dart';

class CreateBudgetPage extends StatefulWidget {
  final DateTime selectedDate;

  const CreateBudgetPage({
    super.key,
    required this.selectedDate
  });

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final TextEditingController _amountController = TextEditingController();
  final NumberFormat _formatter = NumberFormat.decimalPattern();
  String? _selectedCategory;

  bool _toggleActive = false;
  double _alertValue = 50.0;

  final List<String> _categories = [
    'Transportation',
    'Shopping',
    'Subscription',
    'Insurance',
    'Groceries',
  ];

  @override
  Widget build(BuildContext context) {
    bool amountEdited = false;

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final initialHeight = MediaQuery.of(context).size.height * 0.28;
    double topSpaceHeight = _toggleActive ? initialHeight : initialHeight + 37;

    return Scaffold(
      backgroundColor: Colors.blue,

      body: Column(
        children: [
          SizedBox(height: 48),

          _appbar(),

          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isKeyboardVisible ? topSpaceHeight - 240 : topSpaceHeight,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How much do you want to spend?',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _amountController..text = _amountController.text.isEmpty
                  ? '0'
                  : _amountController.text,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold
              ),

              onChanged: (value) {
                final raw = value.replaceAll(',', '');
                if (raw.isEmpty) {
                  _amountController.text = '0';
                } else {
                  final number = int.tryParse(raw);
                  if (number != null) {
                    final newText = _formatter.format(number);
                    _amountController.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: newText.length),
                    );
                  }
                }
              },

              onTap: () {
                if (!amountEdited && _amountController.text == '0') {
                  _amountController.clear();
                  amountEdited = true;
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.grey.withAlpha(5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Colors.grey.withAlpha(40),
                            width: 1
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Colors.grey.withAlpha(40),
                            width: 1
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Colors.purple,
                            width: 1.5
                        ),
                      )
                    ),
                    value: _selectedCategory,
                    items: _categories
                        .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategory = value;
                    }),
                  ),

                  SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receive Alert',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                          Text(
                            'Receive alert when it reaches some point',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey
                            ),
                          )
                        ],
                      ),

                      Switch(
                        value: _toggleActive,
                        onChanged: (bool value) {
                          setState(() {
                            _toggleActive = value;
                          });
                        },
                        activeColor: Colors.blue,
                      )
                    ],
                  ),

                  if (_toggleActive)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        activeTrackColor: Colors.deepPurpleAccent,
                        inactiveTrackColor: Colors.grey.shade300,
                        trackShape: AlertSliderTrack(),

                        thumbShape: AlertSliderThumb(),
                        thumbColor: Colors.deepPurpleAccent,
                        disabledThumbColor: Colors.white,

                        overlayColor: Colors.deepPurpleAccent.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 28),

                        tickMarkShape: SliderTickMarkShape.noTickMark,
                      ),
                      child: Slider(
                        value: _alertValue,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        onChanged: (double value) {
                          setState(() {
                            _alertValue = value;
                          });
                        },
                      ),
                    ),

                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final rawAmount = _amountController.text.replaceAll(',', '');
                        final amount = double.tryParse(rawAmount) ?? 0;
                        final selectedCategoryIndex = _categories.indexOf(_selectedCategory ?? '');

                        if (amount <= 0 || _selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final categoryId = (selectedCategoryIndex + 1).toString();

                        try {
                          await ApiService.createBudget(
                            selectedDate: widget.selectedDate,
                            amount: amount,
                            categoryId: categoryId,
                            alertValue: _toggleActive ? _alertValue : null
                          );

                          Fluttertoast.showToast(
                            msg: "Budget Created",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );

                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create budget!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          debugPrint('ERROR: $e');
                        }

                        debugPrint('AMOUNT: $amount');
                        debugPrint('CATEGORY_ID: $categoryId');
                        debugPrint('ALERT_VALUE: ${_toggleActive ? _alertValue : null}');
                      },
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _appbar() {
    return Container(
      height: 84,
      padding: EdgeInsets.symmetric(vertical: 16 , horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          Center(
            child: Text(
              "Create Budget",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
    );
  }
}