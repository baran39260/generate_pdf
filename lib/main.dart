import 'dart:math';
import 'package:flutter/material.dart';
import 'package:generate_pdf/settings_dialog.dart';

import 'invoice_generator.dart';
import 'models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Generator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _productCount = 25;
  int _transactionCount = 2;
  PDFSettingsStruct _pdfSettings = PDFSettingsStruct();
  String _selectedTheme = 'Modern'; // Default theme

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invoice Settings'),
          content: SettingsDialog(
            settings: _pdfSettings,
            onSettingsChanged: (settings) {
              setState(() {
                _pdfSettings = settings;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _generateInvoice() async {
    List<InvoiceItemsDataStruct> products = createRandomProducts(_productCount);
    InvoicesRecord invoiceDoc = generateSampleInvoice();
    CurrencyDataStruct currencyData = generateSampleCurrencyData();
    List<TransactionsRecord> transactions = createSampleTransactions(_transactionCount);

    await generateInvoicePdf(
      context,
      products,
      invoiceDoc,
      _pdfSettings,
      currencyData,
      transactions,
      theme: _selectedTheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Number of Products: $_productCount'),
            Slider(
              value: _productCount.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: _productCount.toString(),
              onChanged: (double value) {
                setState(() {
                  _productCount = value.toInt();
                });
              },
            ),
            Text('Number of Transactions: $_transactionCount'),
            Slider(
              value: _transactionCount.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: _transactionCount.toString(),
              onChanged: (double value) {
                setState(() {
                  _transactionCount = value.toInt();
                });
              },
            ),
            DropdownButton<String>(
              value: _selectedTheme,
              items: ['Modern', 'Classic'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _generateInvoice,
              child: Text('Create Invoice'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsDialog,
        tooltip: 'Settings',
        child: Icon(Icons.settings),
      ),
    );
  }

  List<InvoiceItemsDataStruct> createRandomProducts(int count) {
    final random = Random();
    final products = <InvoiceItemsDataStruct>[];

    for (int i = 0; i < count; i++) {
      final name = 'Product ${String.fromCharCode(65 + random.nextInt(26))}';
      final unit = random.nextBool() ? 'pcs' : 'kg';
      final quantity = random.nextInt(10) + 1;
      final salesPrice = random.nextDouble() * 100;
      final discount = random.nextDouble() * 0.1;
      final tax = random.nextDouble() * 0.1;

      products.add(InvoiceItemsDataStruct(
        name: name,
        unit: unit,
        quantity: quantity,
        salesPrice: salesPrice,
        discount: discount,
        tax: tax,
      ));
    }

    return products;
  }

  InvoicesRecord generateSampleInvoice() {
    return InvoicesRecord(
      generalInvoiceInfo: GeneralInvoiceInfoStruct(
        invoiceNumber: 'INV-001',
        creationDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)),
        termsAndConditions: 'Payment within 30 days.',
        paymentMethods: 'Bank transfer, Credit card',
        signatureImage: 'https://img.icons8.com/avantgarde/100/signature.png',
      ),
      invoiceType: 1,
      buyerRef: 'buyer_123',
      bizRef: 'biz_456',
    );
  }

  CurrencyDataStruct generateSampleCurrencyData() {
    return CurrencyDataStruct(
      symbol: '\$',
      showSymbol: true,
      symbolOnLeft: true,
      spaceBetweenAmountAndSymbol: false,
      thousandsSeparator: ',',
      decimalSeparator: '.',
      digit: 2,
      useParenthesesForNegatives: false,
    );
  }

  List<TransactionsRecord> createSampleTransactions(int count) {
    final random = Random();
    return List.generate(count, (index) {
      return TransactionsRecord(
        date: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        note: 'Transaction ${index + 1}',
        transactionDataItem: List.generate(2, (index) {
          return TransactionItemDataStruct(
            amount: random.nextDouble() * 100,
          );
        }),
      );
    });
  }
}
