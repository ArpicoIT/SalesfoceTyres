import '../models/step_result.dart';
import 'flow_stage.dart';

class FlowStep {
  final String id;
  final String title;
  final FlowStage initialStage;


  /// API execution logic
  final Future<StepResult> Function() execute;

  /// Retry config
  final int retryCount;
  final Duration retryDelay;

  /// Recall (polling) config
  final int recallCount;
  final Duration recallDelay;

  const FlowStep({
    required this.id,
    required this.title,
    required this.execute,
    this.initialStage = FlowStage.IDLE,
    this.retryCount = 3,
    this.retryDelay = const Duration(seconds: 5),
    this.recallCount = 0,
    this.recallDelay = const Duration(seconds: 30),
  });
}
