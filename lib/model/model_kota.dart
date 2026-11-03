class ModelKota {
  String? id;
  String? lokasi;

  ModelKota(this.id, this.lokasi);

  ModelKota.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lokasi = json['lokasi'];
  }

  @override
  String toString() => lokasi as String;

  static List<ModelKota> fromJsonList(List list) {
    if (list.isEmpty) return List<ModelKota>.empty();
    return list.map((item) => ModelKota.fromJson(item)).toList();
  }
}