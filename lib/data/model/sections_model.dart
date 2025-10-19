
class SectionsModel {
  static const String collectionName = 'sections';
  String? id;
  String? name;
  bool? isIncome;

  SectionsModel({this.id, this.name, this.isIncome});

  SectionsModel.fromFireStore(Map<String, dynamic>? data)
    : this(id: data?['id'], name: data?['name'], isIncome: data?['isIncome']);

  Map<String, dynamic> toFireStore() {
    return {'id': id, 'name': name, 'isIncome': isIncome};
  }
}
