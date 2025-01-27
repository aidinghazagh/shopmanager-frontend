class InventoryLog{
  final int quantityChange;
  final DateTime createdAt;

  InventoryLog({
    required this.quantityChange,
    required this.createdAt,
  });


  factory InventoryLog.fromJson(Map<String, dynamic> json) {
    return InventoryLog(
      quantityChange: json['quantity_change'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}