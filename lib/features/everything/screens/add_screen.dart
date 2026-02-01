import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaya/features/anga/services/anga_repository.dart';

/// Screen for adding a new bookmark or note.
class AddScreen extends ConsumerStatefulWidget {
  static const routePath = '/add';
  static const routeName = 'add';

  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isUrl {
    final text = _controller.text.trim();
    if (text.startsWith('http://') || text.startsWith('https://')) {
      try {
        final uri = Uri.parse(text);
        return uri.hasScheme && uri.host.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
    if (text.startsWith('www.')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bookmark or Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'URL or Note',
                hintText: 'Enter a URL to bookmark or text for a note',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              minLines: 3,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.text.isEmpty
                  ? 'Enter a URL or text'
                  : _isUrl
                      ? 'Will be saved as a bookmark'
                      : 'Will be saved as a note',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _controller.text.trim().isEmpty || _saving
                        ? null
                        : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Saving',
                            ),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _saving = true;
    });

    try {
      final repo = ref.read(angaRepositoryProvider.notifier);

      if (_isUrl) {
        // Add protocol if missing
        var url = text;
        if (text.startsWith('www.')) {
          url = 'https://$text';
        }
        await repo.addBookmark(url);
      } else {
        await repo.addNote(text);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
