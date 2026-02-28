import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_manager/bloc_manager.dart';
import 'package:bloc_manager_example/cubits/posts/posts_cubit.dart';

/// Posts Screen demonstrates PaginationBlocMixin.
/// Shows infinite scroll pagination of posts from JSONPlaceholder API.
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<PostsCubit>();
    final position = _scrollController.position;
    if (cubit.paginationInfo?.hasNextPage == true &&
        !cubit.paginationInfo!.isLoadingNextPage) {
      // Trigger load when near bottom (80%)
      if (position.pixels >= position.maxScrollExtent * 0.8) {
        cubit.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (Pagination)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cubit.refresh(),
          ),
        ],
      ),
      body: BlocManager<PostsCubit, BaseState<List<dynamic>>>(
        bloc: cubit,
        showLoadingIndicator: false, // We handle loading per item
        child: BlocBuilder<PostsCubit, BaseState<List<dynamic>>>(
          builder: (context, state) {
            if (state is InitialState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LoadingState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading posts...'),
                  ],
                ),
              );
            }

            if (state is ErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => cubit.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is LoadedState) {
              final posts = state.data ?? [];

              if (posts.isEmpty) {
                return const Center(child: Text('No posts available'));
              }

              return Column(
                children: [
                  // Pagination info
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${posts.length} posts',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (cubit.paginationInfo != null)
                          Text(
                            'Page ${cubit.currentPage} of ${cubit.paginationInfo?.totalPages ?? '?'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  // Posts list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: posts.length + (cubit.hasNextPage ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= posts.length) {
                          // Loading indicator for next page
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final post = posts[index] as dynamic;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('#${post.id ?? '?'}'),
                            ),
                            title: Text(
                              post.title ?? 'Untitled',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              post.body ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
