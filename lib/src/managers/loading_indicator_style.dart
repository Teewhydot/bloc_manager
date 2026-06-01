/// The style of the loading indicator to show when a Bloc is in the LoadingState.
enum LoadingIndicatorStyle {
  /// Shows a full-screen loading overlay over the content.
  fullScreenOverlay,

  /// Shows a loading indicator anchored to the bottom as a bottom sheet.
  bottomSheet,

  /// Shows a thin linear progress bar pinned to the top edge (like YouTube).
  /// Non-intrusive — does not obscure the content underneath.
  topProgressBar,

  /// Shows a frosted glass (blurred backdrop) overlay over the content.
  /// Uses [BackdropFilter] with [ImageFilter.blur] for the glass effect,
  /// with a semi-transparent tint overlay and a centered loading indicator.
  frostedGlass,
}
