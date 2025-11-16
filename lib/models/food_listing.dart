import 'package:hive/hive.dart';

part 'food_listing.g.dart';

@HiveType(typeId: 1)
class FoodListing {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? imageUrl;

  @HiveField(3)
  final String statusProximidadeVencimento;

  @HiveField(4)
  final DateTime expiryDate;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String contactInfo;

  @HiveField(7)
  final String quantity;

  FoodListing({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.statusProximidadeVencimento,
    required this.expiryDate,
    required this.description,
    required this.contactInfo,
    required this.quantity,
  });

  FoodListing copyWith({
    int? id,
    String? title,
    String? imageUrl,
    String? statusProximidadeVencimento,
    DateTime? expiryDate,
    String? description,
    String? contactInfo,
    String? quantity,
  }) {
    return FoodListing(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      statusProximidadeVencimento:
          statusProximidadeVencimento ?? this.statusProximidadeVencimento,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
      quantity: quantity ?? this.quantity,
    );
  }
}
