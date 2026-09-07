import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleSearchScreen extends StatefulWidget {
  const ArticleSearchScreen({super.key, required this.topic});

  final String topic;

  @override
  State<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends State<ArticleSearchScreen> {
  static const _blue = Color(0xff0b83d9);
  WebViewController? _controller;
  int _progress = 0;
  bool _failed = false;
  String _host = 'www.google.com';

  Uri get _searchUri =>
      Uri.https('www.google.com', '/search', {'q': widget.topic});

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      _controller = WebViewController();
      _initialize();
    }
  }

  Future<void> _initialize() async {
    try {
      final controller = _controller!;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.white);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            return uri != null &&
                    (uri.scheme == 'https' || uri.scheme == 'http')
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _failed = false;
              _progress = 0;
              _host = Uri.tryParse(url)?.host ?? _host;
            });
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() => _failed = true);
            }
          },
        ),
      );
      await controller.loadRequest(_searchUri);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _failed = false;
      _progress = 0;
    });
    await _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xfff7f8fa),
                      foregroundColor: _blue,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Tips & Articles',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff131415),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.topic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Color(0xff666e80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xfff7f8fa),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _host,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Color(0xff666e80),
                ),
              ),
            ),
            SizedBox(
              height: 2,
              child: _controller != null && !_failed && _progress < 100
                  ? LinearProgressIndicator(
                      value: _progress == 0 ? null : _progress / 100,
                      color: _blue,
                      backgroundColor: const Color(0xffe7f3fb),
                    )
                  : null,
            ),
            Expanded(
              child: _controller == null || _failed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.travel_explore_rounded,
                              size: 40,
                              color: _blue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _controller == null
                                  ? 'Open the mobile app to explore this topic.'
                                  : 'Unable to load this page. Check your connection and try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xff666e80),
                              ),
                            ),
                            if (_controller != null) ...[
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _retry,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Try again'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : WebViewWidget(controller: _controller!),
            ),
          ],
        ),
      ),
    );
  }
}
