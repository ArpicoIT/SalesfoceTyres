import 'package:flutter/material.dart';

import '../engine/async_flow_engine.dart';
import '../engine/flow_stage.dart';
import '../models/flow_result.dart';
import 'flow_stage_icon.dart';

class AsyncFlowSheet extends StatefulWidget {
  final AsyncFlowEngine engine;
  final String title;

  const AsyncFlowSheet({
    super.key,
    required this.engine,
    required this.title,
  });

  static Future<FlowResult?> open({
    required BuildContext context,
    required AsyncFlowEngine engine,
    String title = 'Async Flow',
  }) {
    return showModalBottomSheet<FlowResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AsyncFlowSheet(engine: engine, title: title),
    );
  }

  @override
  State<AsyncFlowSheet> createState() => _AsyncFlowSheetState();
}

class _AsyncFlowSheetState extends State<AsyncFlowSheet> {
  FlowResult? result;
  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    result = await widget.engine.start();
    // if (mounted) {
    //   Navigator.of(context).pop(result);
    // }
  }

  void _reStart() async {
    widget.engine.reset();
    result = await widget.engine.start();
  }

  void _cancel() async {
    widget.engine.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ValueListenableBuilder(
                  valueListenable: widget.engine.currentStepIndex,
                  builder: (_, index, _) {
                    return Text(
                      'Step ${index + 1} of ${widget.engine.steps.length}',
                    );
                  },
                ),

                const SizedBox(height: 8),

                ValueListenableBuilder(
                  valueListenable: widget.engine.stage,
                  builder: (_, stage, _) {
                    return FlowStageIcon(stage: stage, size: 72);
                  },
                ),

                const SizedBox(height: 8),

                ValueListenableBuilder(
                  valueListenable: widget.engine.stage,
                  builder: (_, stage, _) {
                    final message = _getMessages(stage)['message'];
                    return message != null
                        ? Text(
                            message,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: widget.engine.stage,
            builder: (_, stage, _) {
              return Row(children: _buildActionButtons(stage));
            },
          ),
        ],
      ),
    );
  }

  Map<String, String> _getMessages(FlowStage stage) {
    switch (stage) {
      case FlowStage.IDLE:
        return {'title': widget.title, 'message': 'Preparing request...'};

      case FlowStage.WAITING:
        return {
          'title': 'Processing',
          'message': 'Request is being processed. Please wait...',
        };

      case FlowStage.REQUESTING:
        return {'title': 'Connecting', 'message': 'Making API request...'};

      case FlowStage.UPLOADING:
        return {'title': 'Uploading', 'message': 'Uploading data to server...'};

      case FlowStage.DOWNLOADING:
        return {
          'title': 'Downloading',
          'message': 'Downloading data from server...',
        };

      case FlowStage.NETWORK_ERROR:
        return {
          'title': 'Network Error',
          'message':
              'Connection issue detected. Please check your network and retry.',
        };

      case FlowStage.SUCCESS:
        return {
          'title': 'Success',
          'message': 'Operation completed successfully.',
        };

      // case FlowStage.APPROVED:
      //   return {
      //     'title': 'Approved',
      //     'message': 'Request completed successfully.',
      //   };
      //
      // case FlowStage.REJECTED:
      //   return {
      //     'title': 'Rejected',
      //     'message': 'The request was rejected. Please review and try again.',
      //   };
      //
      // case FlowStage.CANCELLED:
      //   return {
      //     'title': 'Canceled',
      //     'message': 'The request was canceled. Please review and try again.',
      //   };

      case FlowStage.FAILED:
        return {
          'title': 'Error',
          'message': 'Something went wrong. You can retry or close.',
        };

      case FlowStage.TIMEOUT:
        return {
          'title': 'Timed Out',
          'message':
              'No response was received within the allowed time. Please retry.',
        };
    }
  }

  List<Widget> _buildActionButtons(FlowStage stage) {
    switch (stage) {
      case FlowStage.IDLE:
      case FlowStage.REQUESTING:
      case FlowStage.UPLOADING:
      case FlowStage.DOWNLOADING:
      case FlowStage.WAITING:
        return [
          Expanded(child: _buildButton('Cancel', Colors.redAccent, _cancel)),
        ];
      case FlowStage.SUCCESS:
        return [
          Expanded(
            child: _buildButton(
              'Go Back',
              Colors.green,
              () => Navigator.of(context).pop(result),
            ),
          ),
        ];
      case FlowStage.NETWORK_ERROR:
      case FlowStage.FAILED:
      case FlowStage.TIMEOUT:
        return [
          Expanded(
            child: _buildButton(
              'Close',
              Colors.grey,
              () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              'Retry',
              Theme.of(context).colorScheme.primary,
              _reStart,
            ),
          ),
        ];
    }
  }

  Widget _buildButton(String label, Color color, VoidCallback? onPressed) {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  void dispose() {
    widget.engine.cancel();
    super.dispose();
  }
}
