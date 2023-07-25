// Import library yang diperlukan
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class Transaction {
  final String name;
  final double amount;
  final String date;
  final String description;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.description,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> transactions = [];

  String nameInput = '';
  String amountInput = '';
  String descriptionInput = '';

  DateTime selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _addTransaction(String name, String amount, String description) {
    String date = _dateController.text;

    if (amount.isEmpty || date.isEmpty) {
      return;
    }

    final amountWithoutRp = amount.replaceAll('Rp ', '');
    final parsedAmount = double.tryParse(amountWithoutRp);

    if (parsedAmount == null) {
      return;
    }

    setState(() {
      transactions.add(Transaction(
        name: name,
        amount: parsedAmount,
        date: date,
        description: description,
      ));
    });

    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Pencatat Keuangan'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Card(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nama'),
                    onChanged: (value) => nameInput = value,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => amountInput = value,
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Tanggal'),
                        controller: _dateController,
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Tanggal harus diisi';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Keterangan'),
                    onChanged: (value) => descriptionInput = value,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addTransaction(nameInput, amountInput, descriptionInput);
                      amountInput = '';
                    },
                    child: Text('Tambah Transaksi'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (ctx, index) {
                final transaction = transactions[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.money),
                    title: Text(transaction.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${transaction.date}'),
                        Text('Keterangan: ${transaction.description}'),
                        Text(
                            'Rp ${NumberFormat("#,###").format(transaction.amount)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          transactions.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
