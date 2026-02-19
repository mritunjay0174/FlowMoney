import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/enums.dart';
import 'database_service.dart';

class DataSeeder {
  static const _uuid = Uuid();

  static Future<void> seedIfNeeded(DatabaseService db) async {
    final existing = await db.getAllCategories();
    if (existing.isNotEmpty) return;

    final expenseCategories = [
      ('Food & Dining', 'restaurant', 'F43F5E'),
      ('Coffee & Drinks', 'local_cafe', '8B5CF6'),
      ('Groceries', 'shopping_cart', '10B981'),
      ('Transport', 'directions_car', '3B82F6'),
      ('Shopping', 'shopping_bag', 'EC4899'),
      ('Entertainment', 'movie', 'F97316'),
      ('Health & Fitness', 'fitness_center', '14B8A6'),
      ('Bills & Utilities', 'receipt_long', '6366F1'),
      ('Housing & Rent', 'home', 'F59E0B'),
      ('Education', 'school', '06B6D4'),
      ('Travel', 'flight', '84CC16'),
      ('Personal Care', 'spa', 'A78BFA'),
      ('Gifts', 'card_giftcard', 'FB7185'),
      ('Pets', 'pets', 'FDBA74'),
      ('Other', 'more_horiz', '9CA3AF'),
    ];

    final incomeCategories = [
      ('Salary', 'work', '10B981'),
      ('Freelance', 'laptop', '6366F1'),
      ('Investment', 'trending_up', '3B82F6'),
      ('Gift / Bonus', 'card_giftcard', 'F59E0B'),
      ('Refund', 'replay', '06B6D4'),
      ('Other Income', 'attach_money', '10B981'),
    ];

    int order = 0;
    for (final (name, icon, hex) in expenseCategories) {
      await db.insertCategory(Category(
        id: _uuid.v4(),
        name: name,
        iconName: icon,
        colorHex: hex,
        type: TransactionType.expense,
        sortOrder: order++,
        isSystem: true,
      ));
    }

    order = 0;
    for (final (name, icon, hex) in incomeCategories) {
      await db.insertCategory(Category(
        id: _uuid.v4(),
        name: name,
        iconName: icon,
        colorHex: hex,
        type: TransactionType.income,
        sortOrder: order++,
        isSystem: true,
      ));
    }
  }
}
