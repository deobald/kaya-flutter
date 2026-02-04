import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaya/features/account/screens/troubleshooting_screen.dart';
import 'package:kaya/features/account/services/account_repository.dart';
import 'package:kaya/features/sync/services/sync_service.dart';

/// Screen for managing account settings.
class AccountScreen extends ConsumerStatefulWidget {
  static const routePath = '/account';
  static const routeName = 'account';

  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _serverController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _testing = false;
  bool _syncing = false;
  bool _loaded = false;

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (_loaded) return;

    final repo = await ref.read(accountRepositoryProvider.future);
    final settings = await repo.loadSettings();
    final password = await repo.getPassword();

    _serverController.text = settings.serverUrl;
    _emailController.text = settings.email ?? '';
    _passwordController.text = password ?? '';

    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(accountSettingsNotifierProvider);
    final syncStatus = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: settingsAsync.when(
        data: (settings) {
          _loadSettings();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildServerSection(),
                const SizedBox(height: 24),
                _buildCredentialsSection(),
                const SizedBox(height: 24),
                _buildActionsSection(syncStatus),
                const SizedBox(height: 24),
                _buildTroubleshootingSection(),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading settings'),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildServerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: 'Kaya Server',
                hintText: 'https://kaya.town',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => _saveServerUrl(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Credentials', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => _saveEmail(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                ),
              ),
              obscureText: !_passwordVisible,
              onChanged: (_) => _savePassword(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(SyncStatus syncStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testing ? null : _testConnection,
              icon: _testing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: 'Testing connection',
                      ),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: const Text('Test Connection'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _syncing || syncStatus == SyncStatus.syncing
                  ? null
                  : _forceSync,
              icon: _syncing || syncStatus == SyncStatus.syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        semanticsLabel: 'Syncing',
                      ),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Force Sync'),
            ),
            if (syncStatus == SyncStatus.error) ...[
              const SizedBox(height: 8),
              Text(
                'Last sync had errors - check Troubleshooting',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bug_report),
        title: const Text('Troubleshooting'),
        subtitle: const Text('View logs and report issues'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(TroubleshootingScreen.routePath),
      ),
    );
  }

  Future<void> _saveServerUrl() async {
    final notifier = ref.read(accountSettingsNotifierProvider.notifier);
    await notifier.updateServerUrl(_serverController.text.trim());
  }

  Future<void> _saveEmail() async {
    final notifier = ref.read(accountSettingsNotifierProvider.notifier);
    await notifier.updateEmail(_emailController.text.trim());
  }

  Future<void> _savePassword() async {
    final notifier = ref.read(accountSettingsNotifierProvider.notifier);
    await notifier.updatePassword(_passwordController.text);
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
    });

    try {
      final controller = ref.read(syncControllerProvider.notifier);
      final success = await controller.testConnection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Connection successful!' : 'Connection failed',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _testing = false;
        });
      }
    }
  }

  Future<void> _forceSync() async {
    setState(() {
      _syncing = true;
    });

    try {
      final controller = ref.read(syncControllerProvider.notifier);
      final result = await controller.forceSync();

      if (mounted) {
        final message = result.hasErrors
            ? 'Sync completed with errors'
            : result.hasChanges
            ? 'Sync complete: ${result.angaDownloaded + result.metaDownloaded + result.faviconDownloaded + result.wordsDownloaded} downloaded, '
                  '${result.angaUploaded + result.metaUploaded} uploaded'
            : 'Already in sync';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: result.hasErrors ? Colors.orange : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }
}
