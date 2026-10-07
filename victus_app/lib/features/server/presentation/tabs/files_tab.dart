import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class FilesTab extends ConsumerWidget {
  final String serverId;

  const FilesTab({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy files list
    final files = [
      {'name': 'config', 'isDir': true, 'size': '-'},
      {'name': 'plugins', 'isDir': true, 'size': '-'},
      {'name': 'server.properties', 'isDir': false, 'size': '1.2 KB'},
      {'name': 'eula.txt', 'isDir': false, 'size': '184 B'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text('/home/container', style: AppTypography.h4),
              const Spacer(),
              IconButton(icon: const Icon(Icons.add, color: AppColors.textPrimary), onPressed: () {}),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                leading: Icon(
                  file['isDir'] == true ? Icons.folder : Icons.insert_drive_file,
                  color: AppColors.textPrimary,
                ),
                title: Text(file['name'] as String, style: AppTypography.bodyMedium),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(file['size'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                      onPressed: () {},
                    ),
                  ],
                ),
                onTap: () {
                  if (file['isDir'] == false) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FileEditorScreen(filename: file['name'] as String)));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class FileEditorScreen extends StatefulWidget {
  final String filename;
  const FileEditorScreen({super.key, required this.filename});

  @override
  State<FileEditorScreen> createState() => _FileEditorScreenState();
}

class _FileEditorScreenState extends State<FileEditorScreen> {
  final TextEditingController _controller = TextEditingController(text: '# Edit your config here\n');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filename),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: () {
            Navigator.pop(context);
          })
        ],
      ),
      body: TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }
}
