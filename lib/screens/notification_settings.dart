import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _enabled = true;
  bool _testMode = false;
  int _hour = 18;
  int _minute = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getNotificationSettings();
    setState(() {
      _enabled = settings['enabled'] as bool;
      _testMode = settings['testMode'] as bool;
      _hour = settings['hour'] as int;
      _minute = settings['minute'] as int;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _notificationService.setNotificationEnabled(_enabled);
    await _notificationService.setNotificationTime(_hour, _minute);
    await _notificationService.setTestMode(_testMode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive daily recipe notifications'),
            value: _enabled,
            onChanged: (value) async {
              setState(() {
                _enabled = value;
              });
              await _saveSettings();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Test Mode'),
            subtitle: const Text(
              'Send notification every 10 seconds for testing',
              style: TextStyle(fontSize: 12),
            ),
            value: _testMode,
            onChanged: _enabled
                ? (value) async {
                    setState(() {
                      _testMode = value;
                    });
                    await _saveSettings();
                  }
                : null,
          ),
          const Divider(),
          if (!_testMode) ...[
            ListTile(
              title: const Text('Notification Time'),
              subtitle: Text(
                '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _enabled ? _selectTime : null,
            ),
            const Divider(),
          ],
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Testing Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Enable Test Mode to receive notifications every 10 seconds\n'
                    '• Disable Test Mode and set a time for daily notifications\n'
                    '• Notifications will show a random recipe of the day',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

