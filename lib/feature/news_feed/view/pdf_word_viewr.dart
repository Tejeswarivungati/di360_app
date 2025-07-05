import 'dart:io';

import 'package:di360_flutter/common/constants/app_colors.dart';
import 'package:di360_flutter/common/constants/txt_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerScreen({required this.fileUrl, required this.fileName});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    String viewerUrl;

    if (widget.fileName.toLowerCase().endsWith('.pdf')) {
      viewerUrl = widget.fileUrl;
    } else {
      viewerUrl =
          'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.fileUrl)}&embedded=true';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(viewerUrl)),
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });
                await controller.evaluateJavascript(source: """
              document.body.style.backgroundColor = 'white';
              document.documentElement.style.backgroundColor = 'white';
            """);
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to load file.")),
                );
              },
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class PdfViewrWidget extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const PdfViewrWidget({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  State<PdfViewrWidget> createState() => _PdfViewrWidgetState();
}

class _PdfViewrWidgetState extends State<PdfViewrWidget> {
  String? localPath;
  int? totalPages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    final response = await http.get(Uri.parse(widget.fileUrl));
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/temp.pdf";
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes, flush: true);

    setState(() {
      localPath = filePath;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || localPath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PDFView(
      filePath: localPath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: true,
      pageFling: true,
    );
  }
}

Widget webSiteText(String url) {
  final validUrl = url.startsWith('http') ? url : 'https://$url';

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Website Url : ',
          style: TextStyles.medium2(color: AppColors.black),
        ),
        WidgetSpan(
          child: InkWell(
            onTap: () async {
              final uri = Uri.parse(validUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // Handle gracefully if can't launch
                print("Could not launch $validUrl");
              }
            },
            child: Text(
              validUrl,
              style: TextStyles.semiBold(color: Colors.blue, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}
