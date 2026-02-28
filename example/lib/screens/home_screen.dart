import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc_manager_example/cubits/posts/posts_cubit.dart';
import 'package:bloc_manager_example/cubits/pokemon/pokemon_cubit.dart';
import 'package:bloc_manager_example/cubits/products/products_cubit.dart';
import 'package:bloc_manager_example/cubits/todos/todos_cubit.dart';

import 'posts_screen.dart';
import 'pokemon_screen.dart';
import 'products_screen.dart';
import 'todos_screen.dart';

/// Main home screen with tab navigation.
/// Each tab demonstrates a different bloc_manager feature.
/// Central BlocProvider registry manages all cubits.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostsCubit _postsCubit;
  late final PokemonCubit _pokemonCubit;
  late final ProductsCubit _productsCubit;
  late final TodosCubit _todosCubit;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _postsCubit = PostsCubit();
    _pokemonCubit = PokemonCubit()..loadFromCache();
    _productsCubit = ProductsCubit();
    _todosCubit = TodosCubit();
  }

  @override
  void dispose() {
    _postsCubit.close();
    _pokemonCubit.close();
    _productsCubit.close();
    _todosCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _postsCubit),
        BlocProvider.value(value: _pokemonCubit),
        BlocProvider.value(value: _productsCubit),
        BlocProvider.value(value: _todosCubit),
      ],
      child: _HomeContent(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _HomeContent({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const List<Widget> _screens = [
    PostsScreen(),
    PokemonScreen(),
    ProductsScreen(),
    TodosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Posts',
            selectedIcon: Icon(Icons.article_outlined),
          ),
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon),
            label: 'Pokemon',
            selectedIcon: Icon(Icons.catching_pokemon_outlined),
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
            selectedIcon: Icon(Icons.shopping_bag_outlined),
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Todos',
            selectedIcon: Icon(Icons.check_circle_outline),
          ),
        ],
      ),
    );
  }
}
