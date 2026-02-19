/// A Flutter package providing base BLoC/Cubit classes, a BlocManager widget,
/// and utility mixins for common state-management patterns.
library bloc_manager;

// ── Core state ──────────────────────────────────────────────────────────────
export 'src/base/app_state.dart';
export 'src/base/base_state.dart';
export 'src/base/base_bloc.dart';

// ── Widget ───────────────────────────────────────────────────────────────────
export 'src/managers/bloc_manager.dart';
export 'src/managers/bloc_manager_theme.dart';

// ── Mixins ───────────────────────────────────────────────────────────────────
export 'src/mixins/cacheable_bloc_mixin.dart';
export 'src/mixins/pagination_bloc_mixin.dart';
export 'src/mixins/refreshable_bloc_mixin.dart';

// ── Utilities ────────────────────────────────────────────────────────────────
export 'src/utils/logger.dart';
