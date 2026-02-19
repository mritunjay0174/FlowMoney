import 'enums.dart';

class Category {
  final String id;
  final String name;
  final String iconName; // Material Icons codepoint as hex string or name
  final String colorHex;
  final TransactionType type;
  final int sortOrder;
  final bool isSystem;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.type,
    required this.sortOrder,
    this.isSystem = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon_name': iconName,
        'color_hex': colorHex,
        'type': type.dbValue,
        'sort_order': sortOrder,
        'is_system': isSystem ? 1 : 0,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        iconName: map['icon_name'] as String,
        colorHex: map['color_hex'] as String,
        type: TransactionType.fromDb(map['type'] as String),
        sortOrder: map['sort_order'] as int,
        isSystem: (map['is_system'] as int) == 1,
      );
}
