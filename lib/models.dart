import 'package:flutter/material.dart';

class BuyerSellerInfo {
  final String name;
  final String address;
  final String phone;
  final String email;

  BuyerSellerInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });
}

class CurrencyDataStruct {
  final String symbol;
  final bool showSymbol;
  final bool symbolOnLeft;
  final bool spaceBetweenAmountAndSymbol;
  final String thousandsSeparator;
  final String decimalSeparator;
  final int digit;
  final bool useParenthesesForNegatives;

  CurrencyDataStruct({
    required this.symbol,
    required this.showSymbol,
    required this.symbolOnLeft,
    required this.spaceBetweenAmountAndSymbol,
    required this.thousandsSeparator,
    required this.decimalSeparator,
    required this.digit,
    required this.useParenthesesForNegatives,
  });
}

class InvoicesRecord {
  final GeneralInvoiceInfoStruct generalInvoiceInfo;
  final int invoiceType;
  final String buyerRef;
  final String bizRef;

  InvoicesRecord({
    required this.generalInvoiceInfo,
    required this.invoiceType,
    required this.buyerRef,
    required this.bizRef,
  });
}

class InvoiceItemsDataStruct {
  final String name;
  final String unit;
  final int quantity;
  final double salesPrice;
  final double discount;
  final double tax;

  InvoiceItemsDataStruct({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.salesPrice,
    required this.discount,
    required this.tax,
  });
}

class TransactionsRecord {
  final DateTime? date;
  final String note;
  final List<TransactionItemDataStruct> transactionDataItem;

  TransactionsRecord({
    required this.date,
    required this.note,
    required this.transactionDataItem,
  });
}

class TransactionItemDataStruct {
  final double amount;

  TransactionItemDataStruct({
    required this.amount,
  });
}


class PDFSettingsStruct {
  String pageFormat;
  bool isLandscape;
  bool showLogo;
  bool showPaymentMethods;
  bool showTermsAndConditions;
  bool showDiscountPercentageColumn;
  bool showDiscountAmountColumn;
  bool showTaxPercentageColumn;
  bool showTaxAmountColumn;
  bool showSignature;
  bool showUnitColumn;
  bool disableColors;
  bool useBorderColor;
  bool showBackgroundShapes;
  Color headerColor;
  Color footerColor;
  Color infoBoxColor;
  Color borderColor;
  Color backgroundCircleColor1;
  Color backgroundCircleColor2;

  PDFSettingsStruct({
    this.pageFormat = 'A4',
    this.isLandscape = false,
    this.showLogo = true,
    this.showPaymentMethods = true,
    this.showTermsAndConditions = true,
    this.showDiscountPercentageColumn = true,
    this.showDiscountAmountColumn = true,
    this.showTaxPercentageColumn = true,
    this.showTaxAmountColumn = true,
    this.showSignature = true,
    this.showUnitColumn = true,
    this.disableColors = false,
    this.useBorderColor = false,
    this.showBackgroundShapes = true,
    this.headerColor = Colors.teal,
    this.footerColor = Colors.teal,
    this.infoBoxColor = Colors.teal,
    this.borderColor = Colors.black,
    this.backgroundCircleColor1 = Colors.orangeAccent,
    this.backgroundCircleColor2 = Colors.yellowAccent,
  });
}


class GeneralInvoiceInfoStruct {
  final String invoiceNumber;
  final DateTime creationDate;
  final DateTime dueDate;
  final String termsAndConditions;
  final String paymentMethods;
  final String signatureImage;

  GeneralInvoiceInfoStruct({
    required this.invoiceNumber,
    required this.creationDate,
    required this.dueDate,
    required this.termsAndConditions,
    required this.paymentMethods,
    required this.signatureImage,
  });
}

class ItemPriceDataStruct {
  final double priceBeforeDiscount;
  final double discountAmount;
  final double taxAmount;
  final double totalItemAmount;
  final double profit;

  ItemPriceDataStruct({
    required this.priceBeforeDiscount,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalItemAmount,
    required this.profit,
  });
}
