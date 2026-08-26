import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Genera un reporte en PDF (título + tabla) y dispara la descarga con
/// FileSaver — usado por TODOS los botones "Descargar" de la app
/// (Desglose, Plan de Rodaje). Decisión explícita del usuario: ninguna
/// descarga debe salir en CSV/Excel/otro formato, todas en PDF.
///
/// [headers] son los títulos de columna y [rows] cada fila ya formateada
/// a texto (el llamador decide qué mostrar en cada celda). Se usa
/// orientación horizontal (landscape) porque estos reportes tienden a
/// tener muchas columnas angostas.
Future<void> exportTablePdf({
  required String fileName,
  required String titulo,
  String? subtitulo,
  required List<String> headers,
  required List<List<String>> rows,
  List<int>? anchoColumnasFlex,
}) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          if (subtitulo != null && subtitulo.isNotEmpty)
            pw.Text(subtitulo, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 10),
        ],
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          cellHeight: 20,
          columnWidths: anchoColumnasFlex == null
              ? null
              : {
                  for (var i = 0; i < anchoColumnasFlex.length; i++) i: pw.FlexColumnWidth(anchoColumnasFlex[i].toDouble()),
                },
        ),
      ],
    ),
  );

  final bytes = await doc.save();
  await FileSaver.instance.saveFile(
    name: fileName,
    bytes: Uint8List.fromList(bytes),
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}
