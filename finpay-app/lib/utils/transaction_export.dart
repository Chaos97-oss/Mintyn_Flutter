import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/transaction_model.dart';

/// PDF + PNG export helpers for transaction receipts.
abstract final class TransactionExport {
  /// Built-in PDF fonts (Helvetica) lack many Unicode glyphs; keep PDF text ASCII-safe.
  static String _pdfAscii(String s) {
    return s
        .replaceAll('\u2212', '-') // minus sign
        .replaceAll('\u2014', '-') // em dash
        .replaceAll('\u2013', '-') // en dash
        .replaceAll('\u00B7', '.') // middle dot
        .replaceAll('\u2022', '.') // bullet
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('—', '-')
        .replaceAll('·', '.');
  }

  static String _safeFilePart(String s) {
    final x = s.replaceAll(RegExp(r'[^\w\-]+'), '_');
    return x.length > 40 ? x.substring(0, 40) : x;
  }

  // Mirrors `AppColors` / `TransactionReceiptCard` for PDF (RGB 0-1).
  static final PdfColor _pdfPageBg = PdfColors.white;
  static final PdfColor _pdfCard = PdfColor(35 / 255, 35 / 255, 37 / 255);
  static final PdfColor _pdfInnerBg = PdfColor(28 / 255, 28 / 255, 29 / 255);
  static final PdfColor _pdfBorder = PdfColor(39 / 255, 39 / 255, 41 / 255);
  static final PdfColor _pdfTextPrimary = PdfColors.white;
  static final PdfColor _pdfTextSecondary = PdfColor(148 / 255, 163 / 255, 184 / 255);
  static final PdfColor _pdfTextMuted = PdfColor(71 / 255, 85 / 255, 105 / 255);
  static final PdfColor _pdfGreen = PdfColor(34 / 255, 197 / 255, 94 / 255);
  static final PdfColor _pdfRed = PdfColor(239 / 255, 68 / 255, 68 / 255);
  /// Same as `AppColors.green` @ 20% — never use stadium radius 999 in PDF (breaks path geometry).
  static final PdfColor _pdfBadgeGreenFill = PdfColor(34 / 255, 197 / 255, 94 / 255, 0.2);
  static final PdfColor _pdfHairline = PdfColor(39 / 255, 39 / 255, 41 / 255, 0.6);

  static pw.Widget _pdfHairlineRule() {
    return pw.Container(height: 1, color: _pdfHairline);
  }

  static Future<Uint8List> buildPdfBytes(TransactionModel t) async {
    final doc = pw.Document();
    final when = _pdfAscii(DateFormat('MMM d, yyyy · hh:mm a').format(t.timestamp));
    final sign = t.isCredit ? '+' : '-';
    final amt = '$sign \$${t.amount.abs().toStringAsFixed(2)}';
    final amountColor = t.isCredit ? _pdfGreen : _pdfRed;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) {
          final pageFmt = ctx.page.pageFormat;
          final maxCard = math.min(390.0, pageFmt.availableWidth - 72);
          final cardW = math.max(280.0, maxCard);
          return pw.Container(
            color: _pdfPageBg,
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: pw.Container(
              width: cardW,
              decoration: pw.BoxDecoration(
                color: _pdfCard,
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: _pdfBorder, width: 1),
              ),
              padding: const pw.EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: _pdfBadgeGreenFill,
                          borderRadius: pw.BorderRadius.circular(14),
                        ),
                        child: pw.Text(
                          _pdfAscii(t.status),
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: _pdfGreen,
                          ),
                        ),
                      ),
                      pw.Text(
                        'FINPAY',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2,
                          color: _pdfTextMuted,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    _pdfAscii(t.title),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _pdfTextPrimary,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    when,
                    style: pw.TextStyle(fontSize: 13, color: _pdfTextSecondary),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    decoration: pw.BoxDecoration(
                      color: _pdfInnerBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: _pdfBorder),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Amount',
                          style: pw.TextStyle(fontSize: 11, color: _pdfTextMuted),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          amt,
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: amountColor,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _pdfKv('Channel', _pdfAscii(t.channel)),
                  _pdfKv('Merchant / Counterparty', _pdfAscii(t.merchant.isEmpty ? '-' : t.merchant)),
                  _pdfKv('Reference', _pdfAscii(t.referenceId.isEmpty ? '-' : t.referenceId)),
                  if (t.fee != 0) _pdfKv('Fees', '\$${t.fee.abs().toStringAsFixed(2)}'),
                  if (t.notes.isNotEmpty) ...[
                    pw.SizedBox(height: 12),
                    _pdfHairlineRule(),
                    pw.SizedBox(height: 8),
                    pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(
                        'Notes',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: _pdfTextMuted,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _pdfAscii(t.notes),
                      style: pw.TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: _pdfTextSecondary,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 16),
                  _pdfHairlineRule(),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'This document is your official FinPay transaction record.',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _pdfTextMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return doc.save();
  }

  static pw.Widget _pdfKv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 132,
            child: pw.Text(
              _pdfAscii(k),
              style: pw.TextStyle(
                fontSize: 12,
                color: _pdfTextSecondary,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _pdfAscii(v),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _pdfTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> sharePdf(TransactionModel t) async {
    final bytes = await buildPdfBytes(t);
    final dir = await getTemporaryDirectory();
    final name = 'finpay_receipt_${_safeFilePart(t.referenceId.isEmpty ? t.id : t.referenceId)}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await _shareXFile(file);
  }

  static Future<void> shareReceiptPng(GlobalKey boundaryKey, TransactionModel t) async {
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final ctx = boundaryKey.currentContext;
    if (ctx == null || !ctx.mounted) throw StateError('Receipt not ready for export');

    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('Invalid render target');

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('Could not encode image');

    final pngBytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final name = 'finpay_receipt_${_safeFilePart(t.referenceId.isEmpty ? t.id : t.referenceId)}.png';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(pngBytes);
    await _shareXFile(file);
  }

  /// Share a file; if the share channel is not linked (e.g. after hot reload), copy path and throw a clear message.
  static Future<void> _shareXFile(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'FinPay transaction receipt');
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: file.path));
      throw StateError(
        'Share is unavailable until you fully restart the app (stop Run, then flutter run again). '
        'Receipt saved; file path copied to clipboard.',
      );
    }
  }
}
