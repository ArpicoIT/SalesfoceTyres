/// Enhanced Async Flow Package
///
/// A flexible, extensible package for handling various async operations:
/// - Approval workflows
/// - Data download/upload operations
/// - Multiple API calls with retry logic
/// - Network error handling
///
/// Key Features:
/// - Multiple stage types: IDLE, RUNNING, REQUESTING, UPLOADING, DOWNLOADING,
///   WAITING, APPROVED, REJECTED, SUCCESS, FAILED, NETWORK_ERROR, TIMEOUT, CANCELLED
/// - Different animations for each stage type:
///   * Ripple animation for RUNNING/WAITING
///   * Rotate animation for REQUESTING
///   * Bounce animation for UPLOADING/DOWNLOADING
///   * Slide animation for NETWORK_ERROR
///   * Pulse animation for IDLE/TIMEOUT
///   * No animation for terminal states
/// - Retry and timeout support
/// - Pause/Resume functionality
/// - Beautiful UI with contextual icons and colors
///
/// Usage Example:
/// ```dart
/// final engine = AsyncFlowEngine(
///   steps: [
///     FlowStep(
///       id: 'download',
///       title: 'Download Data',
///       execute: () async {
///         // Your API call or operation
///         return StepResult(stage: FlowStage.SUCCESS);
///       },
///       retryCount: 3,
///       retryDelay: Duration(seconds: 2),
///     ),
///   ],
///   globalTimeout: Duration(minutes: 5),
/// );
///
/// final result = await AsyncFlowSheet.open(
///   context: context,
///   engine: engine,
///   title: 'Downloading Data',
/// );
/// ```
library;

export 'engine/async_flow_engine.dart';
export 'engine/flow_stage.dart';
export 'engine/flow_step.dart';

export 'models/flow_result.dart';
export 'models/step_result.dart';

export 'ui/async_flow_sheet.dart';
export 'ui/flow_stage_icon.dart';
