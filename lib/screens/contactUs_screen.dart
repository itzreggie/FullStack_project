import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Contactuspage extends StatelessWidget {
  final VoidCallback onClose;

  const Contactuspage({super.key, required this.onClose});

  static const String contactEmail = 'rejoice.ekong@student.lut.fi';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black54,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Found a bug, have an idea or want your account deleted? '
                    'Send an email and include your device code from Settings '
                    'if the question is about a device.',
                    style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: SelectableText(
                            contactEmail,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy email',
                          icon: const Icon(Icons.copy, color: Colors.black54),
                          onPressed: () async {
                            await Clipboard.setData(const ClipboardData(text: contactEmail));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email copied'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'We usually answer within a few days.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
