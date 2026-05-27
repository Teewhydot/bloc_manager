import 'package:flutter/material.dart';
import 'package:bloc_manager/bloc_manager.dart';

// A simple cubit to trigger the loading state
class DemoLoadingCubit extends BaseCubit<BaseState<String>> {
  DemoLoadingCubit() : super(const InitialState<String>());

  Future<void> simulateLoading() async {
    emitLoading();
    await Future.delayed(const Duration(seconds: 3));
    // Provide a valid LoadedState and then success
    emit(const LoadedState(data: 'Data loaded successfully!'));
    emitSuccess('Success!');
  }
}

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

  void _triggerLoading(
    LoadingIndicatorStyle style,
    Color? color,
    Widget? widget,
  ) {
    setState(() {
      _currentStyle = style;
      _currentColor = color;
      _currentLoadingWidget = widget;
    });
    // Give Flutter a frame to rebuild the BlocManager with the new config
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.simulateLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<DemoLoadingCubit, BaseState<String>>(
      bloc: _cubit,
      loadingStyle: _currentStyle,
      loadingColor: _currentColor,
      loadingWidget: _currentLoadingWidget,
      showResultSuccessNotifications: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loading Styles Demo'),
        ),
        body: SingleChildScrollView(
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
                      const Icon(Icons.fullscreen,
                          size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text('Full Screen Overlay',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _triggerLoading(
                          LoadingIndicatorStyle.fullScreenOverlay,
                          null, // inherits global blue tint
                          null, // inherits global SpinKit
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
                              child: Icon(Icons.check_circle, color: Colors.green),
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
        ),
      ),
    );
  }
}
