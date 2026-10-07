import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/features/server/presentation/providers/server_detail_provider.dart';

class ConsoleOutput extends ConsumerStatefulWidget {
  final String serverId;

  const ConsoleOutput({Key? key, required this.serverId}) : super(key: key);

  @override
  ConsumerState<ConsoleOutput> createState() => _ConsoleOutputState();
}

class _ConsoleOutputState extends ConsumerState<ConsoleOutput> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 50) {
        if (_autoScroll) setState(() => _autoScroll = false);
      } else {
        if (!_autoScroll) setState(() => _autoScroll = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(consoleMessagesProvider(widget.serverId));

    ref.listen(consoleMessagesProvider(widget.serverId), (_, __) {
      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Container(
      color: const Color(0xFF000000), // Pure black
      child: Stack(
        children: [
          messagesAsync.when(
            data: (messages) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return SelectableText(
                    msg.content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFCCCCCC),
                      fontSize: 12,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          ),
          if (!_autoScroll)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.surfaceElevated,
                onPressed: () {
                  setState(() => _autoScroll = true);
                  _scrollToBottom();
                },
                child: const Icon(Icons.arrow_downward, color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
