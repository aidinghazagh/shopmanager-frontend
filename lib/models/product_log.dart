class ProductLog{
  final String changeField;
  final String oldValue;
  final String newValue;
  final String createdAt;

  ProductLog({
    required this.changeField,
    required this.oldValue,
    required this.newValue,
    required this.createdAt,
  });
}