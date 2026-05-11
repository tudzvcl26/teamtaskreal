import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentModel {
  final String attachmentId;
  final String taskId;
  final String uploadedBy;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final DateTime uploadedAt;

  const AttachmentModel({
    required this.attachmentId,
    required this.taskId,
    required this.uploadedBy,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return AttachmentModel(
      attachmentId: (map['attachmentId'] ?? docId).toString(),
      taskId: (map['taskId'] ?? '').toString(),
      uploadedBy: (map['uploadedBy'] ?? '').toString(),
      fileName: (map['fileName'] ?? '').toString(),
      fileUrl: (map['fileUrl'] ?? '').toString(),
      fileType: (map['fileType'] ?? '').toString(),
      uploadedAt: parseDate(map['uploadedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attachmentId': attachmentId,
      'taskId': taskId,
      'uploadedBy': uploadedBy,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}