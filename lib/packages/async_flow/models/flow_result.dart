import '../engine/flow_stage.dart';

class FlowResult {
  final FlowStage stage;
  final Map<String, dynamic>? data;
  final String? message;

  const FlowResult({required this.stage, this.data, this.message});
}
