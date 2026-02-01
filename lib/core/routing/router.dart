import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaya/features/account/screens/account_screen.dart';
import 'package:kaya/features/account/screens/troubleshooting_screen.dart';
import 'package:kaya/features/errors/screens/errors_list_screen.dart';
import 'package:kaya/features/everything/screens/add_screen.dart';
import 'package:kaya/features/everything/screens/everything_screen.dart';
import 'package:kaya/features/everything/screens/preview_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// App router configuration.
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: EverythingScreen.routePath,
    routes: [
      GoRoute(
        path: EverythingScreen.routePath,
        name: EverythingScreen.routeName,
        builder: (context, state) => const EverythingScreen(),
      ),
      GoRoute(
        path: PreviewScreen.routePath,
        name: PreviewScreen.routeName,
        builder: (context, state) {
          final filename = state.pathParameters['filename']!;
          return PreviewScreen(filename: filename);
        },
      ),
      GoRoute(
        path: AddScreen.routePath,
        name: AddScreen.routeName,
        builder: (context, state) => const AddScreen(),
      ),
      GoRoute(
        path: AccountScreen.routePath,
        name: AccountScreen.routeName,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: TroubleshootingScreen.routePath,
        name: TroubleshootingScreen.routeName,
        builder: (context, state) => const TroubleshootingScreen(),
      ),
      GoRoute(
        path: ErrorsListScreen.routePath,
        name: ErrorsListScreen.routeName,
        builder: (context, state) => const ErrorsListScreen(),
      ),
    ],
  );
}
