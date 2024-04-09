import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MyPDFViewer extends StatefulWidget {
  final String name;
  final String pdfPath;

  const MyPDFViewer({super.key, required this.name, required this.pdfPath});

  @override
  State<MyPDFViewer> createState() => _MyPDFViewerState();
}

class _MyPDFViewerState extends State<MyPDFViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: Text(
          widget.name,
          style: GoogleFonts.roboto(fontSize: 20),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.lightBlue),
      ),
      body: SfPdfViewer.network(
        widget.pdfPath,
        key: _pdfViewerKey,
      ),
    ));
  }
}
