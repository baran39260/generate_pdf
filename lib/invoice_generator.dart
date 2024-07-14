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

Future<void> generateInvoicePdf(
    BuildContext context,
    List<InvoiceItemsDataStruct> products,
    InvoicesRecord invoiceDoc,
    PDFSettingsStruct config,
    CurrencyDataStruct currencyData,
    List<TransactionsRecord>? transactionList, {
      required String theme,
    }) async {
  try {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("fonts/Roboto-Medium.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    double discountTotal = 0;
    double taxTotal = 0;
    double priceTotal = 0;

    for (var product in products) {
      var itemPrices = calculateInvoiceItemPrices(product);
      discountTotal += itemPrices.discountAmount;
      taxTotal += itemPrices.taxAmount;
      priceTotal += itemPrices.totalItemAmount;
    }

    final buyerInfo = await fetchPersonInfo(invoiceDoc.buyerRef);
    final sellerInfo = await fetchBusinessInfo(invoiceDoc.bizRef);

    Uint8List? signatureImageBytes;
    if (invoiceDoc.generalInvoiceInfo.signatureImage.isNotEmpty) {
      signatureImageBytes =
      await loadNetworkImage(invoiceDoc.generalInvoiceInfo.signatureImage);
    }

    PdfPageFormat pageFormat = getPageFormat(config.pageFormat);

    List<TransactionItemDataStruct> allTransactionItems = [];
    if (transactionList != null) {
      for (var transaction in transactionList) {
        allTransactionItems.addAll(transaction.transactionDataItem);
      }
    }

    double? transactionTotal = transactionTotalAmount(allTransactionItems);

    const int itemsPerPage = 20; // Maximum 20 items per page
    final int pageCount = (products.length / itemsPerPage).ceil();

    for (int page = 0; page < pageCount; page++) {
      final currentProducts = products.skip(page * itemsPerPage).take(itemsPerPage).toList();

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: config.isLandscape ? pageFormat.landscape : pageFormat,
            margin: const pw.EdgeInsets.all(28),
            theme: pw.ThemeData.withFont(base: ttf),
            buildBackground: (context) => theme == 'Modern' && config.showBackgroundShapes
                ? pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  buildBackgroundCircle(
                      -100, -100, 300,
                      colorToPdfColor(config.backgroundCircleColor1.withOpacity(0.2))
                  ),
                  buildBackgroundCircle2(
                      0, 0, 150,
                      colorToPdfColor(config.backgroundCircleColor2.withOpacity(0.2))
                  ),
                ],
              ),
            )
                : pw.Container(), // No background for Classic theme
          ),
          header: (pw.Context context) {
            return buildHeader(config, invoiceDoc);
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.bottomCenter,
              margin: const pw.EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: buildFooter(config, signatureImageBytes,
                  invoiceDoc.generalInvoiceInfo.termsAndConditions),
            );
          },
          build: (pw.Context context) {
            List<pw.Widget> content = [
              buildSellerBuyerInfo(buyerInfo, sellerInfo, config),
              pw.SizedBox(height: 16),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                child: buildProductTable(
                  currentProducts,
                  discountTotal,
                  taxTotal,
                  priceTotal,
                  config,
                  currencyData,
                  isLastPage: page == pageCount - 1,
                ),
              ),
              pw.SizedBox(height: 16),
            ];

            if (page == pageCount - 1) {
              // Add totals and transaction section only on the last page
              content.add(
                pw.Container(
                  child: pw.Column(
                    children: [
                      buildTotalSection(
                        config,
                        invoiceDoc.generalInvoiceInfo.paymentMethods,
                        invoiceDoc.generalInvoiceInfo.termsAndConditions,
                        discountTotal,
                        taxTotal,
                        priceTotal,
                        currencyData,
                        transactionTotal,
                      ),
                      if (transactionList != null && transactionList.isNotEmpty)
                        pw.SizedBox(height: 16),
                      if (transactionList != null && transactionList.isNotEmpty)
                        buildTransactionSection(
                          transactionList,
                          currencyData,
                          priceTotal,
                          transactionTotal ?? 0,
                          config,
                        ),
                    ],
                  ),
                ),
              );
            }

            return content;
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error generating PDF: $e');
    }
  }
}
