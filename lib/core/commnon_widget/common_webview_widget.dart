import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/constants.dart';
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

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: getScaffoldColor(),
        appBar: AppBar(
          backgroundColor: getScaffoldColor(),
          elevation: 1,
          leading: AppUtils.backButton(
              onTap: () {
                Navigator.pop(context);
              },
              color: getTextColor()),
          centerTitle: true,
          title: AppUtils.commonTextWidget(
            text: widget.title ?? "WebView",
            textColor: getTextColor(),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: ClipRRect(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          child: Stack(
            children: [
              widget.url != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(
                            url: WebUri.uri(Uri.parse(widget.url ?? ""))),
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                        },
                        onLoadStop: (controller, url) {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            isLoading = true;
                          });
                        },
                        initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            clearCache: true,
                            transparentBackground: true),
                      ),
                    )
                  : const Center(
                      child: Text(
                        "Invalid URL",
                        style: TextStyle(fontSize: 16, color: Colors.red,fontFamily: fontFamily),
                      ),
                    ),
              isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.grey.withOpacity(0.5),
                      child: Center(child: AppUtils.loaderWidget()),
                    )
                  : const SizedBox(),
            ],
          ),
        ));
  }
}
