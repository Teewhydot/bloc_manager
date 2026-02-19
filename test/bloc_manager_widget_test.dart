import 'package:bloc_manager/bloc_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_overlay/loading_overlay.dart';

// ── Minimal cubit for widget tests ────────────────────────────────────────────
class WidgetTestCubit extends BaseCubit<BaseState<String>> {
  WidgetTestCubit() : super(const InitialState());

  void goLoading() => emitLoading();
  void goSuccess() => emitSuccess('Great!');
  void goError() => emitError('Oops!');
  void goLoaded(String data) =>
      emit(LoadedState(data: data, lastUpdated: DateTime.now()));
  void goEmpty() => emit(const EmptyState<String>(message: 'Nothing here'));
}

// ── Helper ────────────────────────────────────────────────────────────────────
Widget _buildTestApp({
  required WidgetTestCubit cubit,
  void Function(BuildContext, BaseState<String>)? onSuccess,
  void Function(BuildContext, BaseState<String>)? onError,
  void Function(BuildContext, BaseState<String>)? listener,
  Widget Function(BuildContext, BaseState<String>)? builder,
  bool showLoadingIndicator = true,
  bool showResultErrorNotifications = true,
  bool showResultSuccessNotifications = false,
  bool enablePullToRefresh = false,
  Future<void> Function()? onRefresh,
  Widget child = const Text('content'),
}) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider.value(
        value: cubit,
        child: BlocManager<WidgetTestCubit, BaseState<String>>(
          bloc: cubit,
          onSuccess: onSuccess,
          onError: onError,
          listener: listener,
          builder: builder,
          showLoadingIndicator: showLoadingIndicator,
          showResultErrorNotifications: showResultErrorNotifications,
          showResultSuccessNotifications: showResultSuccessNotifications,
          enablePullToRefresh: enablePullToRefresh,
          onRefresh: onRefresh,
          child: child,
        ),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────
void main() {
  late WidgetTestCubit cubit;
  setUp(() => cubit = WidgetTestCubit());
  tearDown(() => cubit.close());

  group('child rendering', () {
    testWidgets('renders child in initial state', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('uses builder when provided instead of child', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          builder: (_, state) => const Text('from_builder'),
        ),
      );
      expect(find.text('from_builder'), findsOneWidget);
      expect(find.text('content'), findsNothing);
    });
  });

  group('loading overlay', () {
    testWidgets('shows overlay when LoadingState', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      cubit.goLoading();
      await tester.pump();
      // LoadingOverlay wraps a ModalBarrier while loading.
      expect(find.byType(ModalBarrier), findsWidgets);
    });

    testWidgets('hides overlay when not loading', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      cubit.goLoaded('data');
      await tester.pump();
      // Content should be visible.
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('overlay hidden when showLoadingIndicator=false', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(cubit: cubit, showLoadingIndicator: false),
      );
      cubit.goLoading();
      await tester.pump();
      // LoadingOverlay is absent — the content widget is still directly visible.
      expect(find.byType(LoadingOverlay), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });
  });

  group('error snackbar', () {
    testWidgets('shows error snackbar by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      cubit.goError();
      await tester.pump();
      expect(find.text('Oops!'), findsOneWidget);
    });

    testWidgets('does not show snackbar when showResultErrorNotifications=false',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          showResultErrorNotifications: false,
        ),
      );
      cubit.goError();
      await tester.pump();
      expect(find.text('Oops!'), findsNothing);
    });

    testWidgets('calls onError callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          onError: (_, __) => called = true,
        ),
      );
      cubit.goError();
      await tester.pump();
      expect(called, isTrue);
    });
  });

  group('success handling', () {
    testWidgets('calls onSuccess on SuccessState', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _buildTestApp(cubit: cubit, onSuccess: (_, __) => called = true),
      );
      cubit.goSuccess();
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('calls onSuccess on LoadedState', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _buildTestApp(cubit: cubit, onSuccess: (_, __) => called = true),
      );
      cubit.goLoaded('result');
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('shows success snackbar when showResultSuccessNotifications=true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          showResultSuccessNotifications: true,
        ),
      );
      cubit.goSuccess();
      await tester.pump();
      expect(find.text('Great!'), findsOneWidget);
    });

    testWidgets('does not show success snackbar by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      cubit.goSuccess();
      await tester.pump();
      expect(find.text('Great!'), findsNothing);
    });
  });

  group('custom listener', () {
    testWidgets('custom listener receives all state changes', (tester) async {
      final states = <BaseState<String>>[];
      await tester.pumpWidget(
        _buildTestApp(cubit: cubit, listener: (_, s) => states.add(s)),
      );
      cubit.goLoaded('x');
      await tester.pump();
      cubit.goError();
      await tester.pump();
      expect(states.whereType<LoadedState<String>>(), isNotEmpty);
      expect(states.whereType<ErrorState<String>>(), isNotEmpty);
    });
  });

  group('pull-to-refresh', () {
    testWidgets('shows RefreshIndicator when enablePullToRefresh=true',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          cubit: cubit,
          enablePullToRefresh: true,
          onRefresh: () async {},
          child: const SingleChildScrollView(child: Text('scrollable')),
        ),
      );
      cubit.goLoaded('data');
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('no RefreshIndicator without enablePullToRefresh', (tester) async {
      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });
}
