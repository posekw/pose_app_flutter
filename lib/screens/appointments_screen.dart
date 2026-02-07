import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    // CRITICAL for stability:
    // 1. Initialize controller in initState
    // 2. Use setJavaScriptMode to unrestricted (needed for booking system)
    // 3. Handle errors gracefully
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() { 
                _isLoading = true; 
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() { _isLoading = false; });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Webview Error: ${error.description}');
            // Only show error state for critical failures if needed, 
            // but for now just log it to avoid disrupting user flow for minor asset failures.
          },
          onNavigationRequest: (NavigationRequest request) {
            // potential for deep linking logic here
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://posekw.com/?app_booking=1'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Book Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF1744)), // Red accent
            ),
          if (_hasError)
             Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                  const SizedBox(height: 16),
                  const Text('Failed to load booking page', style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => _controller.reload(),
                    child: const Text('Retry', style: TextStyle(color: Color(0xFFFF1744))),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
