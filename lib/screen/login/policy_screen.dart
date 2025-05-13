import 'package:flutter/material.dart';
import 'package:skiniq/common/color_extension.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.example.com/privacy-policy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: TColor.primary,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}