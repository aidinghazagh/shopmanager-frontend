class Shop{
  String name;
  String language;
  String phone;
  DateTime validUntil;

  Shop({
    required this.name,
    required this.language,
    required this.phone,
    required this.validUntil,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      name: json['name'],
      language: json['language'],
      phone: json['phone'],
      validUntil: DateTime.parse(json['valid_until']),
    );
  }
}