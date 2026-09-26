class Folder {
  final String id;
  final String title;
  final int? groupId;
  final String scope;
  final String createdBy;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.title,
    required this.groupId,
    required this.scope,
    required this.createdBy,
    required this.createdAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      title: json['title'],
      groupId: json['group_id'],
      scope: json['scope'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
