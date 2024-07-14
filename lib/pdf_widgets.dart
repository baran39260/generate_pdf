import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'utils.dart';
import 'pdf_widgets.dart';

PdfColor colorToPdfColor(Color color) {
  return PdfColor.fromInt(color.value);
}

pw.Widget buildSellerBuyerInfo(BuyerSellerInfo buyerInfo, BuyerSellerInfo sellerInfo, PDFSettingsStruct config) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: config.disableColors ? PdfColors.white : colorToPdfColor(config.infoBoxColor),
      borderRadius: pw.BorderRadius.circular(8),
      border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        buildInfoColumn('Seller Information:', sellerInfo, config),
        buildInfoColumn('Buyer Information:', buyerInfo, config),
      ],
    ),
  );
}

pw.Widget buildInfoColumn(String title, BuyerSellerInfo info, PDFSettingsStruct config) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal900,
            fontSize: 10,
          ),
        ),
        pw.Text(
          'Name: ${info.name}',
          style: pw.TextStyle(
            color: config.disableColors ? PdfColors.black : PdfColors.white,
            fontSize: 10,
          ),
        ),
        pw.Text(
          'Address: ${info.address}',
          style: pw.TextStyle(
            color: config.disableColors ? PdfColors.black : PdfColors.white,
            fontSize: 10,
          ),
        ),
        pw.Text(
          'Phone: ${info.phone}',
          style: pw.TextStyle(
            color: config.disableColors ? PdfColors.black : PdfColors.white,
            fontSize: 10,
          ),
        ),
        pw.Text(
          'Email: ${info.email}',
          style: pw.TextStyle(
            color: config.disableColors ? PdfColors.black : PdfColors.white,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}


pw.Widget buildProductTable(
    List<InvoiceItemsDataStruct> products,
    double discountTotal,
    double taxTotal,
    double priceTotal,
    PDFSettingsStruct config,
    CurrencyDataStruct currencyData, {
      required bool isLastPage,
    }) {
  List<pw.TableRow> rows = [buildTableHeader(config)];
  for (var i = 0; i < products.length; i++) {
    rows.add(
      pw.TableRow(
        children: buildTableRow(i, products[i], config, currencyData),
      ),
    );
  }
  if (isLastPage) {
    rows.add(buildTableFooter(
      discountTotal,
      taxTotal,
      priceTotal,
      config,
      currencyData,
    ));
  }

  return pw.Container(
    color: PdfColors.white,
    child: pw.Table(
      border: pw.TableBorder.all(color: config.useBorderColor ? colorToPdfColor(config.borderColor) : PdfColors.teal900, width: 0.5),
      children: rows,
    ),
  );
}

List<pw.Widget> buildTableRow(
    int index,
    InvoiceItemsDataStruct product,
    PDFSettingsStruct config,
    CurrencyDataStruct currencyData,
    ) {
  var itemPrices = calculateInvoiceItemPrices(product);

  List<pw.Widget> cells = [
    buildTableCell((index + 1).toString(), config: config), // Number
    buildTableCell(product.name ?? '', config: config), // Product name
    if (config.showUnitColumn) buildTableCell(product.unit ?? '', config: config), // Unit
    buildTableCell(product.quantity.toString(), config: config), // Quantity
    buildTableCell(formatCurrency(product.salesPrice, currencyData), config: config), // Unit price
  ];

  if (config.showDiscountPercentageColumn) {
    cells.add(
      buildTableCell(formatPercentage(product.discount * 100), config: config), // Discount percentage
    );
  }
  if (config.showDiscountAmountColumn) {
    cells.add(
      buildTableCell(formatCurrency(itemPrices.discountAmount, currencyData), config: config), // Discount amount
    );
  }
  if (config.showTaxPercentageColumn) {
    cells.add(
      buildTableCell(formatPercentage(product.tax * 100), config: config), // Tax percentage
    );
  }
  if (config.showTaxAmountColumn) {
    cells.add(
      buildTableCell(formatCurrency(itemPrices.taxAmount, currencyData), config: config), // Tax amount
    );
  }
  cells.add(
    buildTableCell(formatCurrency(itemPrices.totalItemAmount, currencyData), config: config), // Total price
  );

  return cells;
}

pw.Widget buildTableCell(String content, {bool isHeader = false, required PDFSettingsStruct config}) {
  return pw.Container(
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.all(2),
    child: pw.Text(
      content,
      style: pw.TextStyle(
        fontSize: isHeader ? 10 : 9,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isHeader ? PdfColors.teal900 : PdfColors.black,
      ),
    ),
  );
}

pw.TableRow buildTableHeader(PDFSettingsStruct config) {
  List<pw.Widget> headers = [
    buildHeaderCell('#', 'No.', config),
    buildHeaderCell('Prod', 'Products', config),
    if (config.showUnitColumn) buildHeaderCell('Unit', 'Unit', config),
    buildHeaderCell('Qty', 'Qty', config),
    buildHeaderCell('U.Price', 'Unit Price', config),
  ];

  if (config.showDiscountPercentageColumn) {
    headers.add(buildHeaderCell('Disc %', 'Discount Percentage', config));
  }
  if (config.showDiscountAmountColumn) {
    headers.add(buildHeaderCell('Disc Amt', 'Discount Amount', config));
  }
  if (config.showTaxPercentageColumn) {
    headers.add(buildHeaderCell('Tax %', 'Tax Percentage', config));
  }
  if (config.showTaxAmountColumn) {
    headers.add(buildHeaderCell('Tax Amt', 'Tax Amount', config));
  }
  headers.add(buildHeaderCell('T.Price', 'Total Price', config));

  return pw.TableRow(children: headers);
}

pw.Widget buildHeaderCell(String shortTitle, String fullTitle, PDFSettingsStruct config) {
  final abbreviations = {
    'No.': '#',
    'Products': 'Prod',
    'Unit': 'Unit',
    'Quantity': 'Qty',
    'Unit Price': 'U.Price',
    'Discount Percentage': 'Disc %',
    'Discount Amount': 'Disc Amt',
    'Tax Percentage': 'Tax %',
    'Tax Amount': 'Tax Amt',
    'Total Price': 'T.Price',
  };

  const maxWidth = 80.0; // Adjust this value based on your layout
  const fontSize = 8.0; // Adjust font size based on your layout

  return pw.Container(
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      (fullTitle.length * fontSize) > maxWidth
          ? abbreviations[fullTitle] ?? shortTitle
          : fullTitle,
      style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.TableRow buildTableFooter(
    double discountTotal,
    double taxTotal,
    double priceTotal,
    PDFSettingsStruct config,
    CurrencyDataStruct currencyData,
    ) {
  List<pw.Widget> footers = [
    pw.Container(),
    pw.Container(),
    if (config.showUnitColumn) pw.Container(),
    pw.Container(),
    pw.Container(),
  ];

  if (config.showDiscountPercentageColumn) footers.add(pw.Container());
  if (config.showDiscountAmountColumn) {
    footers.add(buildFooterCell(formatCurrency(discountTotal, currencyData)));
  }
  if (config.showTaxPercentageColumn) footers.add(pw.Container());
  if (config.showTaxAmountColumn) {
    footers.add(buildFooterCell(formatCurrency(taxTotal, currencyData)));
  }
  footers.add(buildFooterCell(formatCurrency(priceTotal, currencyData)));

  return pw.TableRow(children: footers);
}

pw.Widget buildFooterCell(String total) {
  return pw.Container(
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      total,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    ),
  );
}

pw.Widget buildBackgroundCircle(
    double top,
    double left,
    double size,
    PdfColor color,
    ) {
  return pw.Positioned(
    top: top,
    left: left,
    child: pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: color,
        shape: pw.BoxShape.circle,
      ),
    ),
  );
}
pw.Widget buildBackgroundCircle2(
    double bottom,
    double right,
    double size,
    PdfColor color,
    ) {
  return pw.Positioned(
    bottom: bottom,
    right: right,
    child: pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: color,
        shape: pw.BoxShape.rectangle,
      ),
    ),
  );
}
pw.Widget buildHeader(PDFSettingsStruct config, InvoicesRecord invoiceDoc) {
  final formattedCreationDate = DateFormat('yyyy-MM-dd')
      .format(invoiceDoc.generalInvoiceInfo.creationDate);
  final formattedDueDate =
  DateFormat('yyyy-MM-dd').format(invoiceDoc.generalInvoiceInfo.dueDate);

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: config.disableColors ? PdfColors.white : colorToPdfColor(config.headerColor),
      borderRadius: pw.BorderRadius.circular(8),
      border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (config.showLogo) buildLogo(),
        pw.SizedBox(width: 8),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: config.disableColors ? PdfColors.black : PdfColors.white,
          ),
        ),
        pw.Spacer(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Number: ${invoiceDoc.generalInvoiceInfo.invoiceNumber}',
              style: pw.TextStyle(
                fontSize: 10,
                color: config.disableColors ? PdfColors.black : PdfColors.white,
              ),
            ),
            pw.Text(
              'Issue Date: $formattedCreationDate',
              style: pw.TextStyle(
                fontSize: 10,
                color: config.disableColors ? PdfColors.black : PdfColors.white,
              ),
            ),
            pw.Text(
              'Due Date: $formattedDueDate',
              style: pw.TextStyle(
                fontSize: 10,
                color: config.disableColors ? PdfColors.black : PdfColors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


pw.Widget buildLogo() {
  return pw.Container(
    width: 50,
    height: 50,
    decoration: const pw.BoxDecoration(
      color: PdfColors.white,
      shape: pw.BoxShape.circle,
    ),
    child: pw.Center(
      child: pw.Text('LOGO',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.teal900)),
    ),
  );
}

pw.Widget buildFooter(
    PDFSettingsStruct config,
    Uint8List? signatureImage,
    String termsAndConditions,
    ) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: config.disableColors ? PdfColors.white : colorToPdfColor(config.footerColor),
      borderRadius: pw.BorderRadius.circular(8),
      border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
    ),
    child: pw.Center(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (config.showTermsAndConditions && termsAndConditions.isNotEmpty)
            pw.Container(
              width: 200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terms and Conditions:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: config.disableColors ? PdfColors.black : PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    termsAndConditions,
                    style: pw.TextStyle(
                      color: config.disableColors ? PdfColors.black : PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (config.showSignature && signatureImage != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  width: 100,
                  height: 50,
                  child: pw.Image(pw.MemoryImage(signatureImage)),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}


pw.Widget buildTotalSection(
    PDFSettingsStruct config,
    String paymentMethods,
    String termsAndConditions,
    double discountTotal,
    double taxTotal,
    double priceTotal,
    CurrencyDataStruct currencyData,
    double? transactionTotal,
    ) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300,
      borderRadius: pw.BorderRadius.circular(8),
      border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
    ),
    child: pw.Column(
      children: [
        if (config.showTermsAndConditions && termsAndConditions.isNotEmpty)
          buildTotalRow(
              'Discount:', formatCurrency(discountTotal, currencyData)),
        if (config.showTermsAndConditions && termsAndConditions.isNotEmpty)
          buildTotalRow('Tax:', formatCurrency(taxTotal, currencyData)),
        buildTotalRow(
          'Final Total:',
          formatCurrency(priceTotal - discountTotal + taxTotal, currencyData),
          isBold: true,
        ),
        if (config.showPaymentMethods && paymentMethods.isNotEmpty)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Payment Methods:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900)),
                pw.SizedBox(height: 4),
                pw.Text(paymentMethods,
                    style:
                    const pw.TextStyle(color: PdfColors.black, fontSize: 9),
                    textAlign: pw.TextAlign.left),
              ],
            ),
          ),
        if (transactionTotal != null && transactionTotal > 0)
          pw.SizedBox(height: 16),
        if (transactionTotal != null && transactionTotal > 0)
          pw.Container(
            alignment: pw.Alignment.centerLeft,
          ),
      ],
    ),
  );
}

pw.Widget buildTotalRow(String label, String value, {bool isBold = false}) {
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.black,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.black,
          ),
        ),
      ],
    ),
  );
}

pw.Widget buildTransactionSection(
    List<TransactionsRecord> transactions,
    CurrencyDataStruct currencyData,
    double totalAmount,
    double paidAmount,
    PDFSettingsStruct config,
    ) {
  double remainingAmount = totalAmount - paidAmount;

  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey300,
      borderRadius: pw.BorderRadius.circular(8),
      border: config.useBorderColor ? pw.Border.all(color: colorToPdfColor(config.borderColor)) : null,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transaction List',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.teal900,
          ),
        ),
        pw.SizedBox(height: 8),
        buildTransactionTable(transactions, currencyData, config),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Received: ${formatCurrency(paidAmount, currencyData)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.Text(
              'Remaining: ${formatCurrency(remainingAmount, currencyData)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


pw.Widget buildTransactionTable(
    List<TransactionsRecord> transactions,
    CurrencyDataStruct currencyData,
    PDFSettingsStruct config,
    ) {
  transactions.sort((a, b) => a.date!.compareTo(b.date!));

  List<pw.TableRow> rows = [];

  int index = 1;
  for (var transaction in transactions) {
    for (var item in transaction.transactionDataItem) {
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: index % 2 == 0 ? PdfColors.white : PdfColors.grey200,
          ),
          children: [
            buildTableCell(index.toString(), config: config),
            buildTableCell(DateFormat('yyyy-MM-dd').format(transaction.date!), config: config),
            buildTableCell(formatCurrency(item.amount, currencyData), config: config),
            buildTableCell(transaction.note ?? '', config: config),
          ],
        ),
      );
      index++;
    }
  }

  return pw.Container(
    color: PdfColors.white,
    child: pw.Table(
      border: pw.TableBorder.all(color: config.useBorderColor ? colorToPdfColor(config.borderColor) : PdfColors.grey400, width: 0.5),
      children: rows,
    ),
  );
}