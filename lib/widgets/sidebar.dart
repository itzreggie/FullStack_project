import 'package:ahtet/screens/contactUs_screen.dart';
import 'package:ahtet/screens/policyOfPrivacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:ahtet/widgets/SideBarElements/sidebar_button.dart';
import 'package:ahtet/screens/notificationHistory_screen.dart';
import 'package:ahtet/screens/setting_screen.dart';
import 'package:ahtet/services/auth_service.dart';
import 'package:ahtet/services/device_location.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onClose;

  const Sidebar({super.key, required this.onClose});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Location sharing stops until you sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    DeviceLocation.stopTracking();
    onClose();
    Navigator.of(context).popUntil((route) => route.isFirst);
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1, // 0.9 for 90% width
      height: double.infinity,
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
            // Sidebar content in Expanded
            Expanded(
              child: ListView(
                children: [
                  SidebarButton(
                    icon: Icons.notifications,
                    label: 'Notification History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Notificationhistorypage(
                                onClose: () {
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SidebarButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Settingpage(
                                onClose: () {
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SidebarButton(
                    icon: Icons.help_outline,
                    label: 'Contact Us',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Contactuspage(
                                onClose: () {
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SidebarButton(
                    icon: Icons.privacy_tip,
                    label: 'Privacy Policy',
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Policyofprivacy(
                                onClose: () {
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SidebarButton(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    onTap: () => _confirmSignOut(context),
                  ),
                ],
              ),
            ),
            if (AuthService.currentUser?.email != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Signed in as ${AuthService.currentUser!.email}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            // Company logo at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Image.asset(
                  'lib/assets/companylogo copy.webp',
                  height: 60,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}