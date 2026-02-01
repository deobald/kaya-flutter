import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaya/features/errors/screens/errors_list_screen.dart';
import 'package:kaya/features/errors/services/error_service.dart';

/// Orange alert icon that shows when there are errors.
class ErrorAlertIcon extends ConsumerWidget {
  const ErrorAlertIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasErrors = ref.watch(hasErrorsProvider);
    final errorCount = ref.watch(errorCountProvider);

    if (!hasErrors) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: () {
        context.push(ErrorsListScreen.routePath);
      },
      icon: Badge(
        label: Text(errorCount.toString()),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          semanticLabel: 'View errors and warnings',
        ),
      ),
      tooltip: 'View errors and warnings',
    );
  }
}
