import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_manager/bloc_manager.dart';

// ─── Demo Cubit ──────────────────────────────────────────────────────────────

/// Simple cubit that simulates a loading operation.
class DemoLoadingCubit extends BaseCubit<BaseState<String>> {
  DemoLoadingCubit() : super(const InitialState<String>());

  Future<void> simulateLoading() async {
    emitLoading();
    await Future.delayed(const Duration(seconds: 4));
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[800]!,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF424242),
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Icon placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[800]!,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[800],
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
      skeletonBaseColor: Colors.blue.withValues(alpha: 0.3),
      skeletonHighlightColor: Colors.blue.withValues(alpha: 0.6),
      showResultSuccessNotifications: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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

// ─── Inline Skeleton Demo (manages its own cubit) ───────────────────────

/// Skeleton placeholder for an avatar.
class SkeletonAvatar extends StatelessWidget {
  const SkeletonAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[800],
    );
  }
}

/// Skeleton placeholder for a text line at a given width.
class SkeletonTextLine extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonTextLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton placeholder for a stat badge.
class SkeletonStat extends StatelessWidget {
  const SkeletonStat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Demonstrates fine-grained inline skeleton loading using [InlineSkeleton].
///
/// The card header (title + description) stays visible at all times, while
/// the avatar, text body, and stat badges are independently replaced with
/// skeleton placeholders during loading. This shows how `InlineSkeleton`
/// lets you control exactly which parts of your UI get skeletonized.
class InlineSkeletonDemoCard extends StatefulWidget {
  const InlineSkeletonDemoCard({super.key});

  @override
  State<InlineSkeletonDemoCard> createState() => _InlineSkeletonDemoCardState();
}

class _InlineSkeletonDemoCardState extends State<InlineSkeletonDemoCard> {
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
        showLoadingIndicator: false,
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
                // ── Header (always visible) ────────────────────────────
                const Row(
                  children: [
                    Icon(Icons.touch_app, size: 40, color: Colors.pink),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inline Skeleton',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fine-grained skeletons for individual widgets',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Profile card with inline skeletons ────────────────
                BlocBuilder<DemoSkeletonCubit, BaseState<String>>(
                  builder: (context, state) {
                    final isLoading = state.isLoading;
                    return Row(
                      children: [
                        // Avatar — independently skeletonised
                        InlineSkeleton(
                          isLoading: isLoading,
                          skeleton: const SkeletonAvatar(),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/60?img=3',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Text body — independently skeletonised
                        Expanded(
                          child: InlineSkeleton(
                            isLoading: isLoading,
                            skeleton: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonTextLine(width: 160),
                                SizedBox(height: 8),
                                SkeletonTextLine(width: double.infinity),
                                SizedBox(height: 6),
                                SkeletonTextLine(width: 120, height: 12),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jane Doe',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Senior Flutter developer passionate about'
                                  ' beautiful UI and state management.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'jane@example.com',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Stat badges — each independently skeletonised ─────
                BlocBuilder<DemoSkeletonCubit, BaseState<String>>(
                  builder: (context, state) {
                    final isLoading = state.isLoading;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InlineSkeleton(
                          isLoading: isLoading,
                          skeleton: const SkeletonStat(),
                          child: _StatBadge(
                            icon: Icons.star,
                            label: '128',
                            color: Colors.amber,
                          ),
                        ),
                        InlineSkeleton(
                          isLoading: isLoading,
                          skeleton: const SkeletonStat(),
                          child: _StatBadge(
                            icon: Icons.favorite,
                            label: '356',
                            color: Colors.red,
                          ),
                        ),
                        InlineSkeleton(
                          isLoading: isLoading,
                          skeleton: const SkeletonStat(),
                          child: _StatBadge(
                            icon: Icons.share,
                            label: '89',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Action button ─────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: () => _cubit.simulateLoading(),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Simulate Loading'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Header stays visible — only avatar, body, and stats skeletonize',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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

          // Inline Skeleton Demo
          const Text(
            'Inline Skeleton',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Wrap individual widgets with InlineSkeleton to selectively '
              'skeletonize specific parts of your UI while keeping the rest '
              'visible and interactive.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          const InlineSkeletonDemoCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Loading Styles Tab ─────────────────────────────────────────────────────

class LoadingStylesTab extends StatelessWidget {
  final DemoLoadingCubit cubit;
  final LoadingConfig currentConfig;
  final ValueChanged<LoadingConfig> onConfigChanged;

  const LoadingStylesTab({
    super.key,
    required this.cubit,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  void _triggerLoading(LoadingConfig config) {
    onConfigChanged(config);
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
                    onPressed: () =>
                        _triggerLoading(const FullScreenLoadingConfig()),
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
                    onPressed: () =>
                        _triggerLoading(const BottomSheetLoadingConfig()),
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
                      const BottomSheetLoadingConfig(
                        overlayColor: Colors.transparent,
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

          const SizedBox(height: 24),

          // Top Progress Bar Demo
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
                  const Icon(Icons.horizontal_rule,
                      size: 48, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text('Top Progress Bar',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _triggerLoading(
                      const TopProgressBarLoadingConfig(
                        progressColor: Colors.teal,
                      ),
                    ),
                    child: const Text('Trigger Loading'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thin progress bar at top edge — non-intrusive, keeps full UI visible',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Frosted Glass Overlay Demo
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
                  const Icon(Icons.blur_on,
                      size: 48, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text('Frosted Glass',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _triggerLoading(const FrostedGlassLoadingConfig()),
                    child: const Text('Trigger Loading'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Blurred backdrop with BackdropFilter — glass morphism loading overlay',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
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
  LoadingConfig _currentConfig = const FullScreenLoadingConfig();

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
              loadingConfig: _currentConfig,
              showResultSuccessNotifications: true,
              child: LoadingStylesTab(
                cubit: _cubit,
                currentConfig: _currentConfig,
                onConfigChanged: (c) => setState(() => _currentConfig = c),
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
