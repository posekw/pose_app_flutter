import 'package:flutter/material.dart';

// WebView temporarily disabled for iOS build compatibility
// TODO: Re-enable when privacy manifest issue is resolved

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Book Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFFFF1744), size: 80),
              const SizedBox(height: 24),
              const Text(
                'Book Your Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Visit our website to book your photography session',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Show booking URL in a dialog for now
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text('Booking Link', style: TextStyle(color: Colors.white)),
                      content: const SelectableText(
                        'https://posekw.com/?app_booking=1',
                        style: TextStyle(color: Color(0xFFFF1744)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1744),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
