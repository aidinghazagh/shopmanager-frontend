class ProductLog{
  final String changedField;
  final String oldValue;
  final String newValue;
  final DateTime createdAt;

  ProductLog({
    required this.changedField,
    required this.oldValue,
    required this.newValue,
    required this.createdAt,
  });

  factory ProductLog.fromJson(Map<String, dynamic> json) {
    return ProductLog(
      changedField: json['changed_field'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}