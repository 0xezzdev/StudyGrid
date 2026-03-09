class ClassFile {
  final String id;
  final String name;
  final double sizeMB;
  final DateTime uploadedAt;
  final String uploaderName;
  final String type;
  final String? url;
  final String? storagePath;

  const ClassFile({
    required this.id,
    required this.name,
    required this.sizeMB,
    required this.uploadedAt,
    required this.uploaderName,
    required this.type,
    this.url,
    this.storagePath,
  });
}