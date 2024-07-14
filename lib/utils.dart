import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:http/http.dart' as http;
import 'models.dart';

Future<BuyerSellerInfo> fetchPersonInfo(String personId) async {
  return BuyerSellerInfo(
    name: 'John Doe',
    address: '1234 Elm Street, Springfield, USA',
    phone: '+1 234 567 890',
    email: 'john.doe@example.com',
  );
}

Future<BuyerSellerInfo> fetchBusinessInfo(String businessId) async {
  return BuyerSellerInfo(
    name: 'Acme Corporation',
    address: '5678 Oak Street, Springfield, USA',
    phone: '+1 987 654 321',
    email: 'info@acme.com',
  );
}

Future<Uint8List?> loadNetworkImage(String imageUrl) async {
  if (imageUrl.isEmpty) {
    return null;
  }
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load network image');
  }
}

PdfPageFormat getPageFormat(String format) {
  switch (format) {
    case 'A3':
      return PdfPageFormat.a3;
    case 'A4':
      return PdfPageFormat.a4;
    case 'A5':
      return PdfPageFormat.a5;
    case 'Letter':
      return PdfPageFormat.letter;
    case 'Legal':
      return PdfPageFormat.legal;
    default:
      return PdfPageFormat.a4;
  }
}

String formatCurrency(double number, CurrencyDataStruct currencyData) {
  bool isNegative = number < 0;
  number = number.abs();

  String formattedNumber = number.toStringAsFixed(currencyData.digit);

  List<String> parts = formattedNumber.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 && !_allZeros(parts[1]) ? currencyData.decimalSeparator + parts[1] : '';

  String formattedIntegerPart = _addThousandsSeparator(integerPart, currencyData.thousandsSeparator);

  String result = formattedIntegerPart + decimalPart;

  result = _addCurrencySymbol(result, currencyData);

  if (isNegative) {
    result = _handleNegativeNumber(result, currencyData);
  }

  return result;
}

bool _allZeros(String decimalPart) {
  for (int i = 0; i < decimalPart.length; i++) {
    if (decimalPart[i] != '0') {
      return false;
    }
  }
  return true;
}

String _addThousandsSeparator(String integerPart, String separator) {
  List<String> formattedIntegerParts = [];
  int start = integerPart.length % 3 == 0 ? 3 : integerPart.length % 3;
  formattedIntegerParts.add(integerPart.substring(0, start));
  for (int i = start; i < integerPart.length; i += 3) {
    formattedIntegerParts.add(separator + integerPart.substring(i, i + 3));
  }
  return formattedIntegerParts.join('');
}

String _addCurrencySymbol(String result, CurrencyDataStruct currencyData) {
  String symbolPart = '';
  if (currencyData.showSymbol && currencyData.symbol.isNotEmpty) {
    symbolPart = currencyData.symbol + (currencyData.spaceBetweenAmountAndSymbol ? ' ' : '');
  }
  return currencyData.symbolOnLeft ? symbolPart + result : result + symbolPart;
}

String _handleNegativeNumber(String result, CurrencyDataStruct currencyData) {
  if (currencyData.useParenthesesForNegatives) {
    return '(' + result + ')';
  } else {
    return '-' + result;
  }
}
String formatPercentage(double number) {
  String formattedNumber = number.toStringAsFixed(2);
  List<String> parts = formattedNumber.split('.');
  String decimalPart = parts.length > 1 && !_allZeros(parts[1]) ? '.' + parts[1] : '';
  return parts[0] + decimalPart;
}
double? transactionTotalAmount(
    List<TransactionItemDataStruct> transactionDataItem) {
  double totalAmount = 0.0;
  for (var dataItem in transactionDataItem) {
    totalAmount += dataItem.amount;
  }
  return totalAmount;
}

ItemPriceDataStruct calculateInvoiceItemPrices(
    InvoiceItemsDataStruct invoiceitemData) {
  double priceBeforeDiscount = invoiceitemData.salesPrice * invoiceitemData.quantity;
  double discountedPrice = priceBeforeDiscount * (1 - invoiceitemData.discount);
  double discountAmount = priceBeforeDiscount * invoiceitemData.discount;
  double taxAmount = discountedPrice * invoiceitemData.tax;
  double finalPrice = discountedPrice + taxAmount;

  return ItemPriceDataStruct(
    priceBeforeDiscount: priceBeforeDiscount,
    discountAmount: discountAmount,
    taxAmount: taxAmount,
    totalItemAmount: finalPrice,
    profit: finalPrice - (invoiceitemData.salesPrice * invoiceitemData.quantity),
  );
}
