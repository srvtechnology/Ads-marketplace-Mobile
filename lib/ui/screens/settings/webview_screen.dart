import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Trusted domain allowlist for WebView navigation security.
/// Only URLs from these domains (and their subdomains) will be loaded.
const List<String> _trustedDomains = [
  'thebhutanmarket.com',
  'admin.thebhutanmarket.com',
  'staging.thebhutanmarket.com',
  'googleapis.com', // For Google services (maps, etc.)
  'google.com', // OAuth redirects
  'accounts.google.com',
  'apple.com', // Apple Sign In
  'appleid.apple.com',
];

/// Validates if a URL belongs to a trusted domain.
bool _isUrlTrusted(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;

  // Allow data: and about: scheme URLs (for blank pages)
  if (uri.scheme == 'data' || uri.scheme == 'about') return true;

  // Only allow https (no http)
  if (uri.scheme != 'https') return false;

  return _trustedDomains
      .any((domain) => uri.host == domain || uri.host.endsWith('.$domain'));
}

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => WebViewScreen(
        title: arguments['title'] as String,
        url: arguments['url'] as String,
      ),
    );
  }
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Validate initial URL before loading
    if (!_isUrlTrusted(widget.url)) {
      _errorMessage = 'This URL is not allowed for security reasons.';
      return;
    }

    _controller = WebViewController()
      // Restrict JavaScript - only enable for trusted domains that require it
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            // Enable JavaScript only for trusted domains that need it
            if (_isUrlTrusted(url)) {
              _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Failed to load page: ${error.description}';
              isLoading = false;
            });
          },
          // Block navigation to untrusted domains
          onNavigationRequest: (NavigationRequest request) {
            if (!_isUrlTrusted(request.url)) {
              // Block navigation to untrusted URLs
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: widget.title),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: context.color.territoryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.color.textDefaultColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (isLoading)
                  Center(
                    child: UiUtils.progress(
                        normalProgressColor: context.color.territoryColor),
                  ),
              ],
            ),
    );
  }
}
