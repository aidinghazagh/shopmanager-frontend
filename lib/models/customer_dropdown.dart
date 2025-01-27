class CustomerDropDown{
  final int id;
  final String name;

  CustomerDropDown({
    required this.id,
    required this.name,
  });

  factory CustomerDropDown.fromJson(Map<String, dynamic> json) {
    return CustomerDropDown(
      id: json['id'],
      name: json['name'],
    );
  }
}