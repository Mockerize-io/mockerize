class Header {
  final String id;
  final String key;
  final String value;
  bool active;

  Header({
    required this.key,
    required this.value,
    required this.active,
    required this.id,
  });

  Header.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        key = json['key'],
        value = json['value'],
        active = json['active'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
        'active': active,
      };
}
