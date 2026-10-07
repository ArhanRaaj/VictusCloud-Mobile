import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/widgets/app_text_field.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';

class CommandInput extends ConsumerStatefulWidget {
  final String serverId;

  const CommandInput({Key? key, required this.serverId}) : super(key: key);

  @override
  ConsumerState<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends ConsumerState<CommandInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _historyIndex = -1;

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(serverDetailNotifierProvider).sendCommand(widget.serverId, text);
      _controller.clear();
      _historyIndex = -1;
      _focusNode.requestFocus();
    }
  }

  void _navigateHistory(int direction) {
    final history = ref.read(commandHistoryProvider(widget.serverId));
    if (history.isEmpty) return;

    setState(() {
      _historyIndex += direction;
      if (_historyIndex < 0) {
        _historyIndex = -1;
        _controller.clear();
      } else if (_historyIndex >= history.length) {
        _historyIndex = history.length - 1;
      } else {
        _controller.text = history[history.length - 1 - _historyIndex];
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(serverStatusProvider(widget.serverId)).valueOrNull ?? 'offline';
    final isOnline = status != 'offline';

    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                // Implement up/down arrow history logic here using logical keys
              },
              child: AppTextField(
                controller: _controller,
                focusNode: _focusNode,
                hintText: isOnline ? 'Enter command...' : 'Server offline',
                enabled: isOnline,
                style: const TextStyle(fontFamily: 'monospace', color: AppColors.textPrimary),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.textPrimary),
            onPressed: isOnline ? _submit : null,
          ),
        ],
      ),
    );
  }
}
