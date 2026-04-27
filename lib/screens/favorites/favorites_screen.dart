import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../../core/l10n/s.dart';
import '../../widgets/gallery_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    final authStatus = context.read<AuthBloc>().state.status;
    if (authStatus == AuthStatus.authenticated) {
      context.read<FavoritesBloc>().add(const LoadFavorites());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.favorites),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            !prev.isLoggedIn && curr.isLoggedIn,
        listener: (context, _) {
          context.read<FavoritesBloc>().add(const LoadFavorites());
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState.status == AuthStatus.unknown) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!authState.isLoggedIn) {
              return _buildLoginPrompt(context, theme);
            }
            return _buildFavoritesList(context, theme);
          },
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ThemeData theme) {
    final s = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(s.loginToFavorite, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.login),
            label: Text(s.login),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, ThemeData theme) {
    final s = S.of(context);
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state.status == FavoritesStatus.loading &&
            state.favorites.isEmpty) {
          return const LoadingIndicator();
        }
        if (state.status == FavoritesStatus.error) {
          return AppErrorWidget(
            message: state.errorMessage ?? s.failedToLoad,
            onRetry: () =>
                context.read<FavoritesBloc>().add(const LoadFavorites()),
          );
        }
        return RefreshIndicator(
          onRefresh: () {
            final completer = Completer<void>();
            context.read<FavoritesBloc>().add(
                RefreshFavorites(completer: completer));
            return completer.future;
          },
          child: state.favorites.isEmpty
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border,
                                size: 64,
                                color: theme.colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              s.noCloudFavorites,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.saveFromDetail,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final gallery = state.favorites[index];
                    return Slidable(
                      key: ValueKey(gallery.gid),
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              context.read<FavoritesBloc>().add(
                                  RemoveFavorite(
                                    gid: gallery.gid,
                                    token: gallery.token,
                                  ));
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: s.remove,
                          ),
                        ],
                      ),
                      child: GalleryCard(
                        gallery: gallery,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/gallery',
                          arguments: {
                            'gid': gallery.gid,
                            'token': gallery.token,
                          },
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
