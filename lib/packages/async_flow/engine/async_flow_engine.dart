import 'dart:async';
import 'package:flutter/material.dart';

import 'flow_stage.dart';
import 'flow_step.dart';
import '../models/flow_result.dart';
import '../models/step_result.dart';

class AsyncFlowEngine {
  final List<FlowStep> steps;
  final Duration? globalTimeout;

  final ValueNotifier<FlowStage> stage = ValueNotifier(FlowStage.IDLE);

  final ValueNotifier<int> currentStepIndex = ValueNotifier(0);

  bool _paused = false;
  bool _running = false;
  bool _cancelled = false;

  AsyncFlowEngine({required this.steps, this.globalTimeout});

  /// Pause / Resume
  void pause() => _paused = true;
  void resume() => _paused = false;

  /// Reset engine state for retry
  void reset() {
    _paused = false;
    _running = false;
    currentStepIndex.value = 0;
    stage.value = FlowStage.IDLE;
  }

  /// Cancel engine state
  void cancel() {
    _running = false;
    _paused = false;
    _cancelled = true;
  }

  /// Start or retry
  Future<FlowResult> start() async {
    if (_running) {
      // Prevent concurrent runs
      return FlowResult(
        stage: FlowStage.FAILED,
        message: 'Flow is already running',
      );
    }

    _running = true;
    // stage.value = FlowStage.IDLE;

    Map<String, dynamic>? lastPayload;
    final stopwatch = Stopwatch()..start();

    try {
      for (int i = 0; i < steps.length; i++) {
        currentStepIndex.value = i;
        _updateStage(steps[i].initialStage);

        if (_isTimeout(stopwatch)) {
          _updateStage(FlowStage.TIMEOUT);
          return const FlowResult(stage: FlowStage.TIMEOUT);
        }

        final result = await _executeStep(steps[i]);
        _updateStage(result.stage);
        lastPayload = result.payload;

        if (_isTerminal(result.stage)) {
          return FlowResult(stage: result.stage, data: lastPayload);
        }
      }

      return FlowResult(stage: stage.value, data: lastPayload);
    } finally {
      _running = false;
    }
  }

  void _updateStage(FlowStage s) {
    // Always update ValueNotifier on UI thread safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stage.value = s;
    });
  }

  bool _isTimeout(Stopwatch sw) =>
      globalTimeout != null && sw.elapsed > globalTimeout!;

  bool _isTerminal(FlowStage s) =>
      s == FlowStage.SUCCESS ||
      s == FlowStage.FAILED ||
      s == FlowStage.NETWORK_ERROR ||
      s == FlowStage.TIMEOUT;

  Future<StepResult> _executeStep(FlowStep step) async {
    int retryAttempt = 0;

    while (true) {
      if (_cancelled) return const StepResult(stage: FlowStage.FAILED);

      try {
        final result = await step.execute();

        if (_cancelled) return const StepResult(stage: FlowStage.FAILED);

        if (result.stage == FlowStage.WAITING && step.recallCount > 0) {
          return await _handleRecall(step, result);
        }

        return result;
      } catch (_) {
        retryAttempt++;
        if (retryAttempt > step.retryCount || _cancelled) {
          return const StepResult(stage: FlowStage.FAILED);
        }
        await Future.delayed(step.retryDelay);
      }
    }
  }

  Future<StepResult> _handleRecall(FlowStep step, StepResult initial) async {
    _updateStage(FlowStage.WAITING);
    StepResult lastResult = initial;

    for (int i = 0; i < step.recallCount; i++) {
      if (_cancelled) return const StepResult(stage: FlowStage.FAILED);

      while (_paused) {
        if (_cancelled) return const StepResult(stage: FlowStage.FAILED);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await Future.delayed(step.recallDelay);

      if (_cancelled) return const StepResult(stage: FlowStage.FAILED);

      try {
        lastResult = await step.execute();
        _updateStage(lastResult.stage);

        if (lastResult.stage != FlowStage.WAITING) {
          return lastResult;
        }
      } catch (_) {
        if (_cancelled) return const StepResult(stage: FlowStage.FAILED);
        return const StepResult(stage: FlowStage.FAILED);
      }
    }

    return lastResult;
  }
}
