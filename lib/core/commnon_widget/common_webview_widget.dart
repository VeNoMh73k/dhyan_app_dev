import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';

class CommonWebViewWidget extends StatefulWidget {
  final String? url;
  final String? title;

  const CommonWebViewWidget({
    Key? key,
    required this.url,
    this.title,
  }) : super(key: key);

  @override
  State<CommonWebViewWidget> createState() => _CommonWebViewWidgetState();
}

class _CommonWebViewWidgetState extends State<CommonWebViewWidget> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        elevation: 1,
        centerTitle: true,
        title: Text(
          widget.title ?? "WebView",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: widget.url != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(15), // Rounded corners
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url ?? ""))),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            clearCache: true,
          ),
        ),
      )
          : const Center(
        child: Text(
          "Invalid URL",
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}
