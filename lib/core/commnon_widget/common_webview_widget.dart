import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class CommonWebViewWidget extends StatefulWidget {
  String? url;
  String? title;

  CommonWebViewWidget({Key? key, this.url, this.title})
      : super(
          key: key,
        );

  @override
  State<CommonWebViewWidget> createState() => _CommonWebViewWidgetState();
}

class _CommonWebViewWidgetState extends State<CommonWebViewWidget> {
  late final PlatformWebViewController controller;
  bool? isInternetAvailable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checkInternetConnectivity();
    controller = PlatformWebViewController(
      AndroidWebViewControllerCreationParams(),
    )..loadRequest(LoadRequestParams(uri: Uri.parse(widget.url ?? "")));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getScaffoldColor(),
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: AppUtils.commonTextWidget(
          text: widget.title,
          textColor: AppColors.blackColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: controller),
            ).build(context),
    );
  }
}
