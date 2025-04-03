import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15.0),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: 'تفعيل الإشعارات',
                subtitle: 'استلام إشعارات لتذكيرك بمواعيد الدواء',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              _buildSettingItem(
                icon: Icons.volume_up_outlined,
                title: 'الصوت',
                subtitle: 'تشغيل صوت مع الإشعارات',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              _buildSettingItem(
                icon: Icons.vibration_outlined,
                title: 'الاهتزاز',
                subtitle: 'تفعيل الاهتزاز مع الإشعارات',
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              const SizedBox(height: 30.0),
              const Text(
                'عن التطبيق',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15.0),
              _buildInfoItem(
                icon: Icons.info_outline,
                title: 'الإصدار',
                subtitle: '1.0.0',
              ),
              _buildInfoItem(
                icon: Icons.code_outlined,
                title: 'المطور',
                subtitle: 'فريق مذكر الدواء',
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: 'مذكر الدواء',
                      applicationVersion: '1.0.0',
                      applicationIcon: Image.asset(
                        'assets/images/app_icon.png',
                        width: 50,
                        height: 50,
                      ),
                      applicationLegalese: '© 2023 فريق مذكر الدواء',
                      children: [
                        const SizedBox(height: 15.0),
                        const Text(
                          'تطبيق مذكر الدواء يساعدك على تذكر مواعيد تناول الدواء بسهولة وبساطة.',
                          style: TextStyle(fontSize: 14.0),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: const Color(0xFF00BCD4).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'عن التطبيق',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00BCD4),
              size: 24.0,
            ),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00BCD4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00BCD4),
              size: 24.0,
            ),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 