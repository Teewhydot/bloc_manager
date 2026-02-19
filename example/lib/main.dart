import 'dart:async';

import 'package:bloc_manager/bloc_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain model
// ─────────────────────────────────────────────────────────────────────────────
class CounterData {
  final int count;
  const CounterData(this.count);
}

// ─────────────────────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────────────────────
class CounterCubit extends BaseCubit<BaseState<CounterData>> {
  CounterCubit() : super(const InitialState());

  Future<void> increment() => executeAsync(
        action: () async {
          await Future.delayed(const Duration(milliseconds: 300));
          final current =
              (state is LoadedState ? (state.data as CounterData).count : 0);
          return CounterData(current + 1);
        },
        onSuccess: (data) => LoadedState(data: data, lastUpdated: DateTime.now()),
      );

  Future<void> fail() => executeAsync(
        action: () async {
          await Future.delayed(const Duration(milliseconds: 300));
          throw Exception('Intentional error');
        },
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────────────────────
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlocManager Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: BlocProvider(
        create: (_) => CounterCubit(),
        child: const CounterPage(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();

    return BlocManager<CounterCubit, BaseState<CounterData>>(
      bloc: cubit,
      // Pressing the FAB shows a loading overlay; errors pop a red snackbar.
      child: Scaffold(
        appBar: AppBar(title: const Text('BlocManager Example')),
        body: Center(
          child: BlocBuilder<CounterCubit, BaseState<CounterData>>(
            builder: (_, state) {
              final count =
                  state is LoadedState ? (state.data as CounterData).count : 0;
              return Text('Count: $count',
                  style: const TextStyle(fontSize: 40));
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'increment',
              onPressed: cubit.increment,
              label: const Text('Increment'),
              icon: const Icon(Icons.add),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'fail',
              backgroundColor: Colors.red,
              onPressed: cubit.fail,
              label: const Text('Trigger Error'),
              icon: const Icon(Icons.error_outline),
            ),
          ],
        ),
      ),
    );
  }
}
