class ClassFile {
  final int id;
  final int groupId;
  final String name;
  final double sizeMB;
  final String uploadedBy;
  final DateTime createdAt;
  final String folderId;
  final String scope;
  final String type;
  final String? url;
  final String? storagePath;

  const ClassFile({
    required this.id,
    required this.groupId,
    required this.name,
    required this.sizeMB,
    required this.uploadedBy,
    required this.createdAt,
    required this.folderId,
    required this.scope,
    required this.type,
    this.url,
    this.storagePath,
  });
}
