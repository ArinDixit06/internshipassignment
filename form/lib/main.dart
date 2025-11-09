import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Quote Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey), // Changed to grey for black and white theme
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[100],
          surfaceTintColor: Colors.grey[100],
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const QuoteBuilderPage(),
    );
  }
}

class ClientInfo {
  String name;
  String address;
  String reference;

  ClientInfo({this.name = '', this.address = '', this.reference = ''});
}

class LineItem {
  String productName;
  TextEditingController quantityController;
  TextEditingController rateController;
  TextEditingController discountController;
  TextEditingController taxController;

  LineItem({
    this.productName = '',
    required this.quantityController,
    required this.rateController,
    required this.discountController,
    required this.taxController,
  });

  double get quantity => double.tryParse(quantityController.text) ?? 0.0;
  double get rate => double.tryParse(rateController.text) ?? 0.0;
  double get discount => double.tryParse(discountController.text) ?? 0.0;
  double get taxPercentage => double.tryParse(taxController.text) ?? 0.0;

  double get itemTotal {
    // Total = ( (Rate * (1 + (Tax % / 100))) * Qty ) - Discount
    double taxedRate = rate * (1 + (taxPercentage / 100));
    double totalBeforeDiscount = taxedRate * quantity;
    return totalBeforeDiscount - discount;
  }
}

class QuoteBuilderPage extends StatefulWidget {
  const QuoteBuilderPage({super.key});

  @override
  State<QuoteBuilderPage> createState() => _QuoteBuilderPageState();
}

class _QuoteBuilderPageState extends State<QuoteBuilderPage> {
  final ClientInfo _clientInfo = ClientInfo();
  final List<LineItem> _lineItems = [];
  bool _showPreview = false; // State to control preview visibility

  @override
  void initState() {
    super.initState();
    _addLineItem(); // Start with one line item
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add(LineItem(
        quantityController: TextEditingController(),
        rateController: TextEditingController(),
        discountController: TextEditingController(),
        taxController: TextEditingController(),
      ));
      _attachListeners(_lineItems.last);
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems[index].quantityController.dispose();
      _lineItems[index].rateController.dispose();
      _lineItems[index].discountController.dispose();
      _lineItems[index].taxController.dispose();
      _lineItems.removeAt(index);
    });
  }

  void _attachListeners(LineItem item) {
    item.quantityController.addListener(_updateCalculations);
    item.rateController.addListener(_updateCalculations);
    item.discountController.addListener(_updateCalculations);
    item.taxController.addListener(_updateCalculations);
  }

  void _updateCalculations() {
    setState(() {
      // Calculations will be triggered by getters in LineItem
    });
  }

  double get _subtotal {
    return _lineItems.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  double get _grandTotal {
    return _subtotal; // For now, grand total is same as subtotal, can add more logic later
  }

  @override
  void dispose() {
    for (var item in _lineItems) {
      item.quantityController.dispose();
      item.rateController.dispose();
      item.discountController.dispose();
      item.taxController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Quote Builder'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showPreview = !_showPreview;
                });
              },
              icon: const Icon(Icons.print),
              label: Text(_showPreview ? 'Hide Preview' : 'Show Preview'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfoForm(),
            const SizedBox(height: 24),
            _buildLineItemsTable(),
            const SizedBox(height: 24),
            _buildTotalsSection(),
            const SizedBox(height: 24),
            if (_showPreview) _buildPreviewSection(), // Conditionally display preview
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoForm() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder()),
              onChanged: (value) => _clientInfo.name = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Client Address', border: OutlineInputBorder()),
              onChanged: (value) => _clientInfo.address = value,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Reference', border: OutlineInputBorder()),
              onChanged: (value) => _clientInfo.reference = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsTable() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Line Items', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 12,
                      horizontalMargin: 0,
                      columns: const [
                        DataColumn(label: Text('Product/Service')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Rate')),
                        DataColumn(label: Text('Discount')),
                        DataColumn(label: Text('Tax %')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('')), // For remove button
                      ],
                      rows: _lineItems.asMap().entries.map((entry) {
                        int index = entry.key;
                        LineItem item = entry.value;
                        return DataRow(cells: [
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                initialValue: item.productName,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                                onChanged: (value) => item.productName = value,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                controller: item.quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: item.rateController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: item.discountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                controller: item.taxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                              ),
                            ),
                          ),
                          DataCell(Text(item.itemTotal.toStringAsFixed(2))),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeLineItem(index),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _addLineItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Line Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Totals', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: Theme.of(context).textTheme.titleMedium),
                Text('\$${_subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total:', style: Theme.of(context).textTheme.headlineSmall),
                Text('\$${_grandTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: Colors.white, // Ensure white background for bill look
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'SALES RECEIPT',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const Divider(color: Colors.black),
            const SizedBox(height: 16),
            Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.black)),
            Text('Time: ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5)}', style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 16),
            Text('Client Name: ${_clientInfo.name.isEmpty ? 'N/A' : _clientInfo.name}', style: const TextStyle(color: Colors.black)),
            Text('Client Address: ${_clientInfo.address.isEmpty ? 'N/A' : _clientInfo.address}', style: const TextStyle(color: Colors.black)),
            Text('Reference: ${_clientInfo.reference.isEmpty ? 'N/A' : _clientInfo.reference}', style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 24),
            const Divider(color: Colors.black),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                  ],
                ),
                ..._lineItems.map((item) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(item.productName, style: const TextStyle(color: Colors.black))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(item.quantity.toStringAsFixed(0), style: const TextStyle(color: Colors.black))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(item.rate.toStringAsFixed(2), style: const TextStyle(color: Colors.black))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(item.itemTotal.toStringAsFixed(2), style: const TextStyle(color: Colors.black))),
                  ],
                )).toList(),
              ],
            ),
            const Divider(color: Colors.black),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
                Text('\$${_subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total:', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                Text('\$${_grandTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Thank you for your business!',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
