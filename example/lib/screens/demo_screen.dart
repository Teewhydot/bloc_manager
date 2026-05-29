import 'package:flutter/material.dart';
import 'package:bloc_manager/bloc_manager.dart';

// ─── Demo Cubit ──────────────────────────────────────────────────────────────

/// Simple cubit that simulates a loading operation.
class DemoLoadingCubit extends BaseCubit<BaseState<String>> {
  DemoLoadingCubit() : super(const InitialState<String>());

  Future<void> simulateLoading() async {
    emitLoading();
    await Future.delayed(const Duration(seconds: 3));
    emit(const LoadedState(data: 'Data loaded successfully!'));
    emitSuccess('Success!');
  }
}

// ─── Skeleton Widgets for Demos ──────────────────────────────────────────────

/// Skeleton placeholder for a list item (e.g. a post or todo row).
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text lines
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a grid card (e.g. a product tile).
class SkeletonGridItem extends StatelessWidget {
  const SkeletonGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a horizontal card (e.g. a horizontal scroll item).
class SkeletonRowItem extends StatelessWidget {
  const SkeletonRowItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Icon placeholder
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Demo Card (manages its own cubit) ─────────────────────────────

/// A card that demonstrates a skeleton loading scenario with its own cubit.
class SkeletonDemoCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final SkeletonConfig skeletonConfig;

  const SkeletonDemoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.skeletonConfig,
  });

  @override
  State<SkeletonDemoCard> createState() => _SkeletonDemoCardState();
}

class _SkeletonDemoCardState extends State<SkeletonDemoCard> {
  late final DemoSkeletonCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DemoSkeletonCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocManager<DemoSkeletonCubit, BaseState<String>>(
        bloc: _cubit,
        skeletonConfig: widget.skeletonConfig,
        showResultSuccessNotifications: false,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 40, color: widget.iconColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _cubit.simulateLoading(),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Load Data'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Shows 3s of skeleton placeholders then real content',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Colours Skeleton Demo (manages its own cubit) ───────────────────

class CustomShimmerDemo extends StatefulWidget {
  const CustomShimmerDemo({super.key});

  @override
  State<CustomShimmerDemo> createState() => _CustomShimmerDemoState();
}

class _CustomShimmerDemoState extends State<CustomShimmerDemo> {
  late final DemoSkeletonCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DemoSkeletonCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<DemoSkeletonCubit, BaseState<String>>(
      bloc: _cubit,
      skeletonConfig: SkeletonConfig(
        builder: (context, index) => const SkeletonListItem(),
        count: 4,
        orientation: SkeletonOrientation.list,
        spacing: 10.0,
      ),
      skeletonBaseColor: Colors.blue.withValues(alpha: 0.15),
      skeletonHighlightColor: Colors.blue.withValues(alpha: 0.4),
      showResultSuccessNotifications: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.palette, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            const Text(
              'Blue-tinted skeleton shimmer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap button below to see blue shimmer animation',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _cubit.simulateLoading(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Load Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DemoSkeletonCubit (for skeleton demos) ─────────────────────────────────

class DemoSkeletonCubit extends BaseCubit<BaseState<String>> {
  DemoSkeletonCubit() : super(const InitialState<String>());

  Future<void> simulateLoading() async {
    emitLoading();
    await Future.delayed(const Duration(seconds: 4));
    emit(const LoadedState(data: 'Skeleton demo complete!'));
    emitSuccess('Data loaded!');
  }
}

// ─── Skeleton Demo Section ──────────────────────────────────────────────────

class SkeletonDemoSection extends StatelessWidget {
  const SkeletonDemoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Skeleton Loading',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Skeleton placeholders replace the content area during '
              'LoadingState with a shimmer animation. The loading overlay '
              'still works alongside.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),

          // List Skeleton Demo
          SkeletonDemoCard(
            icon: Icons.list_alt,
            iconColor: Colors.teal,
            title: 'List Skeleton',
            description: '6 vertical skeleton items in a scrollable list',
            skeletonConfig: SkeletonConfig(
              builder: (context, index) => const SkeletonListItem(),
              count: 6,
              orientation: SkeletonOrientation.list,
              spacing: 10.0,
            ),
          ),

          const SizedBox(height: 24),

          // Grid Skeleton Demo
          SkeletonDemoCard(
            icon: Icons.grid_view,
            iconColor: Colors.indigo,
            title: 'Grid Skeleton',
            description: '8 skeleton cards in a 2-column grid layout',
            skeletonConfig: SkeletonConfig(
              builder: (context, index) => const SkeletonGridItem(),
              count: 8,
              orientation: SkeletonOrientation.grid,
              crossAxisCount: 2,
              spacing: 10.0,
            ),
          ),

          const SizedBox(height: 24),

          // Row Skeleton Demo
          SkeletonDemoCard(
            icon: Icons.horizontal_distribute,
            iconColor: Colors.deepOrange,
            title: 'Horizontal Row Skeleton',
            description: '5 skeleton items in a horizontal scrollable row',
            skeletonConfig: SkeletonConfig(
              builder: (context, index) => const SkeletonRowItem(),
              count: 5,
              orientation: SkeletonOrientation.row,
              spacing: 12.0,
            ),
          ),

          const SizedBox(height: 32),

          // Custom shimmer colours section
          const Text(
            'Custom Shimmer Colours',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Override shimmer colours via skeletonBaseColor and '
              'skeletonHighlightColor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const CustomShimmerDemo(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Loading Styles Tab (existing demos) ────────────────────────────────────

class LoadingStylesTab extends StatelessWidget {
  final DemoLoadingCubit cubit;
  final LoadingIndicatorStyle currentStyle;
  final Color? currentColor;
  final Widget? currentLoadingWidget;
  final ValueChanged<LoadingIndicatorStyle> onStyleChanged;
  final ValueChanged<Color?> onColorChanged;
  final ValueChanged<Widget?> onWidgetChanged;

  const LoadingStylesTab({
    super.key,
    required this.cubit,
    required this.currentStyle,
    required this.currentColor,
    required this.currentLoadingWidget,
    required this.onStyleChanged,
    required this.onColorChanged,
    required this.onWidgetChanged,
  });

  void _triggerLoading(
    LoadingIndicatorStyle style,
    Color? color,
    Widget? widget,
  ) {
    onStyleChanged(style);
    onColorChanged(color);
    onWidgetChanged(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.simulateLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Showcase the different loading styles available in BlocManager.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),

          // Full Screen Overlay Demo
          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fullscreen, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text('Full Screen Overlay',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _triggerLoading(
                      LoadingIndicatorStyle.fullScreenOverlay,
                      null,
                      null,
                    ),
                    child: const Text('Trigger Loading'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bottom Sheet Overlay Demo
          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.vertical_align_bottom,
                      size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Bottom Sheet Overlay',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _triggerLoading(
                      LoadingIndicatorStyle.bottomSheet,
                      null,
                      const BlocBottomSheetWidget(),
                    ),
                    child: const Text('Trigger Loading'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bottom Sheet No Tint Demo
          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.layers_clear,
                      size: 48, color: Colors.purple),
                  const SizedBox(height: 16),
                  const Text('Bottom Sheet (No Tint)',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _triggerLoading(
                      LoadingIndicatorStyle.bottomSheet,
                      Colors.transparent,
                      const BlocBottomSheetWidget(
                        trailingWidget: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child:
                              Icon(Icons.check_circle, color: Colors.green),
                        ),
                      ),
                    ),
                    child: const Text('Trigger Loading'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Demo Screen ───────────────────────────────────────────────────────

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late final DemoLoadingCubit _cubit;
  LoadingIndicatorStyle _currentStyle = LoadingIndicatorStyle.fullScreenOverlay;
  Color? _currentColor;
  Widget? _currentLoadingWidget;

  @override
  void initState() {
    super.initState();
    _cubit = DemoLoadingCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BlocManager Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.hourglass_empty), text: 'Loading'),
              Tab(icon: Icon(Icons.dashboard_customize), text: 'Skeletons'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Loading Styles ───────────────────────────────────
            BlocManager<DemoLoadingCubit, BaseState<String>>(
              bloc: _cubit,
              loadingStyle: _currentStyle,
              loadingColor: _currentColor,
              loadingWidget: _currentLoadingWidget,
              showResultSuccessNotifications: true,
              child: LoadingStylesTab(
                cubit: _cubit,
                currentStyle: _currentStyle,
                currentColor: _currentColor,
                currentLoadingWidget: _currentLoadingWidget,
                onStyleChanged: (s) => setState(() => _currentStyle = s),
                onColorChanged: (c) => setState(() => _currentColor = c),
                onWidgetChanged: (w) =>
                    setState(() => _currentLoadingWidget = w),
              ),
            ),

            // ── Tab 2: Skeleton Loading ───────────────────────────────
            const SkeletonDemoSection(),
          ],
        ),
      ),
    );
  }
}
