class RoleCard {
  const RoleCard({
    required this.id,
    required this.roleName,
    required this.company,
    required this.location,
    required this.level,
    required this.tags,
    required this.summary,
    required this.industry,
  });

  factory RoleCard.fromJson(Map<String, dynamic> json) {
    return RoleCard(
      id: json['id'].toString(),
      roleName: json['role_name'].toString(),
      company: json['company'].toString(),
      location: json['location'].toString(),
      level: json['level'].toString(),
      tags: (json['tags'] as List? ?? const []).map((item) => item.toString()).toList(),
      summary: json['summary'].toString(),
      industry: json['industry'].toString(),
    );
  }

  final String id;
  final String roleName;
  final String company;
  final String location;
  final String level;
  final List<String> tags;
  final String summary;
  final String industry;
}

class RoleLibraryPage {
  const RoleLibraryPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory RoleLibraryPage.fromJson(Map<String, dynamic> json) {
    return RoleLibraryPage(
      items: (json['items'] as List? ?? const [])
          .map((item) => RoleCard.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 8,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  final List<RoleCard> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}
