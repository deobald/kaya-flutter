import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaya/core/widgets/error_alert_icon.dart';
import 'package:kaya/features/account/screens/account_screen.dart';
import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:kaya/features/anga/widgets/anga_tile.dart';
import 'package:kaya/features/everything/screens/add_screen.dart';
import 'package:kaya/features/everything/screens/preview_screen.dart';
import 'package:kaya/features/search/services/search_service.dart';

/// The main screen showing all angas in a searchable grid.
class EverythingScreen extends ConsumerStatefulWidget {
  static const routePath = '/';
  static const routeName = 'everything';

  const EverythingScreen({super.key});

  @override
  ConsumerState<EverythingScreen> createState() => _EverythingScreenState();
}

class _EverythingScreenState extends ConsumerState<EverythingScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: const Text('Kaya'),
        actions: [
          const ErrorAlertIcon(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AddScreen.routePath),
            tooltip: 'Add bookmark or note',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Kaya',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Local-first bookmarks & notes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Everything'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                context.push(AccountScreen.routePath);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  tooltip: 'Clear search',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final angasAsync = _searchQuery.isEmpty
        ? ref.watch(angaRepositoryProvider)
        : ref.watch(filteredAngasProvider(_searchQuery));

    return angasAsync.when(
      data: (angas) {
        if (angas.isEmpty) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _calculateCrossAxisCount(constraints);
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: angas.length,
              itemBuilder: (context, index) {
                final anga = angas[index];
                return AngaTile(
                  anga: anga,
                  onTap: () {
                    context.push(PreviewScreen.routePathFor(anga.filename));
                  },
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading content',
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading content: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(angaRepositoryProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(BoxConstraints constraints) {
    final width = constraints.maxWidth;

    // Tablet: 4 columns
    if (width >= 768) {
      return 4;
    }

    // Large phone or landscape: 3 columns
    if (width >= 480) {
      return 3;
    }

    // Small phone: 2 columns
    return 2;
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks or notes yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Share content to Kaya or tap + to add',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
