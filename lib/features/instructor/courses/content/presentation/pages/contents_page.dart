import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/courses/content/presentation/cubit/content_cubit.dart';

class ContentsPage extends StatefulWidget {

  const ContentsPage({
    super.key,
    required this.courseId,
    this.courseTitle = 'Course Content',
  });
  final String courseId;
  final String courseTitle;

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
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contents.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final updated = List<ContentEntity>.from(contents);
          final item = updated.removeAt(oldIndex);
          updated.insert(newIndex, item);
          context.read<ContentCubit>().reorderContent(
                courseId: widget.courseId,
                contentIds: updated.map((c) => c.id).toList(),
              );
        },
        itemBuilder: (context, index) {
          final content = contents[index];
          return _buildContentCard(content, key: ValueKey(content.id));
        },
      ),
    );
  }

  Widget _buildContentCard(ContentEntity content, {Key? key}) {
    final iconData = _contentTypeIcon(content.contentType);
    final color = _contentTypeColor(content.contentType);

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: _contentIndex(content.id),
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            // Type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            // Title & meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content.description != null &&
                      content.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      content.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(content.contentType.value),
                      const SizedBox(width: 8),
                      Icon(Icons.storage, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(
                        content.formattedSize,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit',
              onPressed: () => _showEditDialog(context, content),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Delete',
              color: Colors.red[400],
              onPressed: () => _confirmDelete(context, content),
            ),
          ],
        ),
      ),
    );
  }

  int _contentIndex(String contentId) {
    final state = context.read<ContentCubit>().state;
    if (state is ContentLoaded) {
      return state.contents.indexWhere((c) => c.id == contentId);
    }
    return 0;
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

  void _showEditDialog(BuildContext context, ContentEntity content) {
    final titleController = TextEditingController(text: content.title);
    final descriptionController = TextEditingController(
      text: content.description ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Content'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Title',
                controller: titleController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Description',
                controller: descriptionController,
                maxLines: 3,
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
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                context.read<ContentCubit>().updateContent(
                      courseId: widget.courseId,
                      contentId: content.id,
                      title: newTitle,
                      description: descriptionController.text.trim(),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ContentEntity content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text('Are you sure you want to delete "${content.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ContentCubit>().deleteContent(
                    courseId: widget.courseId,
                    contentId: content.id,
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
              AppTextField(
                label: 'Title',
                hint: 'e.g. Intro Lecture',
                controller: titleController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Description (optional)',
                hint: 'Brief description',
                controller: descriptionController,
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
