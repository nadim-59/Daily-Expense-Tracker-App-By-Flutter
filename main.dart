import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final List<Map<String, dynamic>> _expenses = [];
  final List<Map<String, dynamic>> _borrowed = [];
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _lastAddedRecord;

  void _addExpense(String description, String amount) {
    if (description.isNotEmpty && amount.isNotEmpty) {
      setState(() {
        _expenses.add({
          'description': description,
          'amount': double.parse(amount),
          'date': _selectedDate,
        });
        _lastAddedRecord = {
          'description': description,
          'amount': double.parse(amount),
          'date': _selectedDate,
          'type': 'Expense',
        };
      });
    }
  }

  void _addBorrowed(String description, String amount) {
    if (description.isNotEmpty && amount.isNotEmpty) {
      setState(() {
        _borrowed.add({
          'description': description,
          'amount': double.parse(amount),
          'date': _selectedDate,
        });
        _lastAddedRecord = {
          'description': description,
          'amount': double.parse(amount),
          'date': _selectedDate,
          'type': 'Borrow',
        };
      });
    }
  }

  void _resetExpenses() {
    setState(() {
      _expenses.clear();
      _borrowed.clear();
      _lastAddedRecord = null;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _showNotebookPage(context);
    }
  }

  void _showNotebookPage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToRecordPage(context, 'Expense');
                },
                child: Text('Expense'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToRecordPage(context, 'Borrow');
                },
                child: Text('Borrow'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToRecordPage(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordBookPage(
          type: type,
          date: _selectedDate,
          addRecord: type == 'Expense' ? _addExpense : _addBorrowed,
        ),
      ),
    ).then((value) {
      // This will run after the user adds the record and returns
      if (_lastAddedRecord != null) {
        setState(() {
          _lastAddedRecord = _lastAddedRecord; // Keep the record in memory
        });
      }
    });
  }

  double _calculateTotal(String type) {
    double total = 0;
    final records = type == 'Expense' ? _expenses : _borrowed;
    for (var record in records) {
      total += record['amount'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _resetExpenses,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Notification Bar (Only visible when a record is added)
            if (_lastAddedRecord != null)
              GestureDetector(
                onTap: () {
                  // Open the details page when the bar is clicked
                  _navigateToRecordPage(
                    context,
                    _lastAddedRecord!['type'],
                  );
                },
                child: Container(
                  color: Colors.blue, // Change background color as needed
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Description: ${_lastAddedRecord!['description']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Date: ${_lastAddedRecord!['date'].toLocal()}'.split(' ')[0],
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Amount: \$${_lastAddedRecord!['amount']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),
            // Date Selection and other actions
            Row(
              children: [
                Text(
                  'Date: ${_selectedDate.toLocal()}'.split(' ')[0], // Format the date
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display the total expense and total borrowed
            Divider(),
            Text(
              'Total Expense: \$${_calculateTotal('Expense').toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Total Borrowed: \$${_calculateTotal('Borrow').toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordBookPage extends StatefulWidget {
  final String type;
  final DateTime date;
  final Function addRecord;

  RecordBookPage({required this.type, required this.date, required this.addRecord});

  @override
  _RecordBookPageState createState() => _RecordBookPageState();
}

class _RecordBookPageState extends State<RecordBookPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Record for: ${widget.date.toLocal()}'.split(' ')[0]),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.addRecord(_descriptionController.text, _amountController.text);
                Navigator.pop(context);
              },
              child: Text('Add ${widget.type}'),
            ),
          ],
        ),
      ),
    );
  }
}
