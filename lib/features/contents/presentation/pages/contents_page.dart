import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/presentation/cubit/content_cubit.dart';

class ContentsPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const ContentsPage({
    super.key,
    required this.courseId,
    this.courseTitle = 'Course Content',
  });

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContentCubit>().getContents(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload Content',
            onPressed: () => _showUploadDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ContentCubit, ContentState>(
        listener: (context, state) {
          if (state is ContentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is ContentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            ContentInitial() => const SizedBox.shrink(),
            ContentLoading() =>
              const AppLoadingWidget(message: 'Loading content...'),
            ContentLoaded(:final contents) => _buildContentList(contents),
            ContentActionSuccess() =>
              const AppLoadingWidget(message: 'Processing...'),
            ContentError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () =>
                    context.read<ContentCubit>().getContents(widget.courseId),
              ),
          };
        },
      ),
    );
  }

  Widget _buildContentList(List<ContentEntity> contents) {
    if (contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No content yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload videos, documents, or PDFs',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ContentCubit>().getContents(widget.courseId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final content = contents[index];
          return _buildContentCard(content);
        },
      ),
    );
  }

  Widget _buildContentCard(ContentEntity content) {
    final iconData = _contentTypeIcon(content.contentType);
    final color = _contentTypeColor(content.contentType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Open content (play video, view document, etc.)
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (content.description != null &&
                        content.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        content.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildTag(content.contentType.value),
                        const SizedBox(width: 8),
                        Icon(Icons.storage, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          content.formattedSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _contentTypeColor(ContentType.fromString(label)).withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _contentTypeColor(ContentType.fromString(label)),
        ),
      ),
    );
  }

  IconData _contentTypeIcon(ContentType type) {
    return switch (type) {
      ContentType.video => Icons.play_circle,
      ContentType.document => Icons.article,
      ContentType.pdf => Icons.picture_as_pdf,
    };
  }

  Color _contentTypeColor(ContentType type) {
    return switch (type) {
      ContentType.video => Colors.blue,
      ContentType.document => Colors.orange,
      ContentType.pdf => Colors.red,
    };
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Content'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Intro Lecture',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open file picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File picker not yet implemented'),
                    ),
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose File'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                context.read<ContentCubit>().uploadContent(
                      courseId: widget.courseId,
                      filePath: '/placeholder/path',
                      title: title,
                      description: descriptionController.text.trim(),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
