import '../engine/flow_stage.dart';

class StepResult {
  final FlowStage stage;
  final Map<String, dynamic>? payload;

  const StepResult({required this.stage, this.payload});
}
