import 'package:flutter/material.dart';

class Policyofprivacy extends StatelessWidget {
  final VoidCallback onClose;

  const Policyofprivacy({super.key, required this.onClose});

  static const List<Map<String, String>> _sections = [
    {
      'title': 'What we collect',
      'body':
          'Your email address for your account. When location sharing is on, '
          'the location of this device, its name and its device code. The safe '
          'zones, routes and tasks you create, and any photos you add to tasks.',
    },
    {
      'title': 'Who can see it',
      'body':
          'Only you can see your safe zones, routes, tasks and notification '
          'history. A device location can be seen by you and by people who '
          'connected to your device with its code. Change your code in Settings '
          'to stop sharing with everyone who has the old one.',
    },
    {
      'title': 'Location in the background',
      'body':
          'If you turn on location sharing, the app keeps sending your location '
          'while it is closed so connected people get safe zone alerts. You can '
          'turn it off at any time in Settings. Signing out also stops it.',
    },
    {
      'title': 'Where it is stored',
      'body':
          'Data is stored in a Supabase database and file storage. Maps and '
          'place search use Mapbox and Google Places, which receive the search '
          'text and map position needed to answer the request.',
    },
    {
      'title': 'Removing your data',
      'body':
          'Deleting a safe zone, route, task or connection removes it from the '
          'database. To remove your whole account and all of its data, contact '
          'us from the Contact Us page.',
    },
  ];

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
                    'Policy of Privacy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final section in _sections) ...[
                    Text(
                      section['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section['body']!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
