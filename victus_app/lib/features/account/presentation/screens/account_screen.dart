import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
final biometricAuthProvider = StateProvider<bool>((ref) => false);

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  bool _isPanelLinked = false;
  
  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }
  
  Future<void> _loadBiometricStatus() async {
    final status = await _secureStorage.read(key: 'biometric_enabled');
    if (status == 'true') {
      ref.read(biometricAuthProvider.notifier).state = true;
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      try {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isSupported = await _localAuth.isDeviceSupported();
        if (canCheckBiometrics && isSupported) {
          final authenticated = await _localAuth.authenticate(
            localizedReason: 'Enable Biometric Authentication',
            options: const AuthenticationOptions(stickyAuth: true),
          );
          if (authenticated) {
            await _secureStorage.write(key: 'biometric_enabled', value: 'true');
            ref.read(biometricAuthProvider.notifier).state = true;
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else {
      await _secureStorage.delete(key: 'biometric_enabled');
      ref.read(biometricAuthProvider.notifier).state = false;
    }
  }

  void _showLinkPanelDialog() {
    final panelEmailController = TextEditingController();
    final panelPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Link Panel Account', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: panelEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Panel Email',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: panelPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Panel Password',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPanelLinked = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Panel Account Linked Successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Link', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool global) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(global ? 'Log Out All Devices' : 'Log Out', style: const TextStyle(color: Colors.white)),
        content: Text(
          global ? 'Are you sure you want to log out from all devices?' : 'Are you sure you want to log out?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (global) {
                await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
              } else {
                await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
              }
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final themeMode = ref.watch(themeModeProvider);
    final isBiometricEnabled = ref.watch(biometricAuthProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Account', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white12,
                      radius: 30,
                      child: Text(
                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.email ?? 'Unknown Email',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UID: ${user?.id ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isPanelLinked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Panel Linked', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: _showLinkPanelDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Link Panel Account'),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('SECURITY', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.white),
            title: const Text('Change Password', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.white),
            title: const Text('Two-Factor Authentication', style: TextStyle(color: Colors.white)),
            trailing: const Text('Disabled', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
          SwitchListTile(
            activeColor: Colors.white,
            activeTrackColor: Colors.white38,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
            title: const Text('Biometric Authentication', style: TextStyle(color: Colors.white)),
            secondary: const Icon(Icons.fingerprint, color: Colors.white),
            value: isBiometricEnabled,
            onChanged: _toggleBiometrics,
          ),
          
          const SizedBox(height: 24),
          const Text('PREFERENCES', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.white),
            title: const Text('Theme', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).state = mode;
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: const Text('Language', style: TextStyle(color: Colors.white)),
            trailing: const Text('English', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          const Text('COMMUNITY & LINKS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.discord, color: Colors.white),
            title: const Text('Discord', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
            onTap: () => _launchUrl('https://discord.gg/victus'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('Status Page', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
            onTap: () => _launchUrl('https://status.victus.com'),
          ),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.white),
            title: const Text('Website', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
            onTap: () => _launchUrl('https://victus.com'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.white),
            title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
            onTap: () => _launchUrl('https://victus.com/tos'),
          ),
          
          const SizedBox(height: 24),
          const Text('SESSION', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () => _showLogoutDialog(false),
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.white),
            title: const Text('Log Out All Devices', style: TextStyle(color: Colors.white)),
            onTap: () => _showLogoutDialog(true),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
