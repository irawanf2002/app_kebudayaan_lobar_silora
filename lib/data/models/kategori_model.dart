class KategoriModel {
  final int? id;
  final String name;
  final String? iconUrl;

  KategoriModel({this.id, required this.name, this.iconUrl});

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse((json['id'] ?? '').toString()),
      name: (json['name'] ?? json['nama'] ?? '').toString(),
      iconUrl: (json['iconUrl'] ?? json['icon_url'] ?? json['icon'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name, 'icon_url': iconUrl};
  }
}
