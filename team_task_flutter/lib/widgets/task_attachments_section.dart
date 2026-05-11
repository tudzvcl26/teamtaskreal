import 'package:flutter/material.dart';

import '../models/attachment_model.dart';

class TaskAttachmentsSection extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final VoidCallback? onAddPressed;
  final Future<String> Function(String userId)? getUserName;
  final void Function(AttachmentModel attachment)? onDelete;
  final bool Function(AttachmentModel attachment)? canDelete;
  final void Function(AttachmentModel attachment)? onTapAttachment;

  const TaskAttachmentsSection({
    super.key,
    required this.attachments,
    this.onAddPressed,
    this.getUserName,
    this.onDelete,
    this.canDelete,
    this.onTapAttachment,
  });

  static const String _headlineFont = 'Manrope';
  static const String _bodyFont = 'Inter';

  bool _isImageAttachment(AttachmentModel attachment) {
    final type = attachment.fileType.toLowerCase();
    final name = attachment.fileName.toLowerCase();

    return type.contains('image') ||
        name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif');
  }

  IconData _iconForFileType(String type, String fileName) {
    final lowerType = type.toLowerCase();
    final lowerName = fileName.toLowerCase();

    if (lowerType.contains('image') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.gif')) {
      return Icons.image_outlined;
    }

    if (lowerType.contains('pdf') || lowerName.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    }

    if (lowerType.contains('doc') ||
        lowerName.endsWith('.doc') ||
        lowerName.endsWith('.docx')) {
      return Icons.description_outlined;
    }

    if (lowerType.contains('xls') ||
        lowerName.endsWith('.xls') ||
        lowerName.endsWith('.xlsx')) {
      return Icons.table_chart_outlined;
    }

    if (lowerType.contains('link')) {
      return Icons.link_outlined;
    }

    return Icons.attach_file_outlined;
  }

  Color _iconBg(String type, String fileName) {
    final icon = _iconForFileType(type, fileName);

    if (icon == Icons.image_outlined) return Colors.blue.shade50;
    if (icon == Icons.picture_as_pdf_outlined) return Colors.red.shade50;
    if (icon == Icons.description_outlined) return Colors.indigo.shade50;
    if (icon == Icons.table_chart_outlined) return Colors.green.shade50;
    if (icon == Icons.link_outlined) return Colors.orange.shade50;

    return Colors.grey.shade100;
  }

  Color _iconColor(String type, String fileName) {
    final icon = _iconForFileType(type, fileName);

    if (icon == Icons.image_outlined) return Colors.blue;
    if (icon == Icons.picture_as_pdf_outlined) return Colors.red;
    if (icon == Icons.description_outlined) return Colors.indigo;
    if (icon == Icons.table_chart_outlined) return Colors.green;
    if (icon == Icons.link_outlined) return Colors.orange;

    return Colors.grey;
  }

  String _formatDate(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildLeading(AttachmentModel attachment) {
    final bg = _iconBg(attachment.fileType, attachment.fileName);
    final color = _iconColor(attachment.fileType, attachment.fileName);
    final icon = _iconForFileType(attachment.fileType, attachment.fileName);

    if (_isImageAttachment(attachment) && attachment.fileUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          attachment.fileUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return CircleAvatar(
              radius: 22,
              backgroundColor: bg,
              child: Icon(icon, color: color),
            );
          },
        ),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: bg,
      child: Icon(icon, color: color),
    );
  }

  Widget _attachmentItem(AttachmentModel attachment) {
    final canShowDelete =
        onDelete != null && (canDelete?.call(attachment) ?? true);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTapAttachment == null ? null : () => onTapAttachment!(attachment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            _buildLeading(attachment),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: _headlineFont,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Loại: ${attachment.fileType.isEmpty ? 'file' : attachment.fileType}',
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (getUserName != null)
                    FutureBuilder<String>(
                      future: getUserName!(attachment.uploadedBy),
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? 'Người dùng';

                        return Text(
                          'Tải lên bởi $name • ${_formatDate(attachment.uploadedAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _bodyFont,
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      _formatDate(attachment.uploadedAt),
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (canShowDelete)
              IconButton(
                onPressed: () => onDelete!(attachment),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tệp đính kèm',
                  style: TextStyle(
                    fontFamily: _headlineFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onAddPressed != null)
                TextButton.icon(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Thêm',
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (attachments.isEmpty)
            Text(
              'Chưa có tệp đính kèm',
              style: TextStyle(
                fontFamily: _bodyFont,
                color: Colors.grey.shade600,
              ),
            )
          else
            Column(
              children: attachments.map(_attachmentItem).toList(),
            ),
        ],
      ),
    );
  }
}