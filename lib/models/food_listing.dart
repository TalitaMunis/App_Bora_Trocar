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

  @HiveField(8)
  final bool isMockUserOwner;

  FoodListing({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.statusProximidadeVencimento,
    required this.expiryDate,
    required this.description,
    required this.contactInfo,
    required this.quantity,
    this.isMockUserOwner = false,
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
    bool? isMockUserOwner,
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
      isMockUserOwner: isMockUserOwner ?? this.isMockUserOwner,
    );
  }
}

// --- DADOS MOCKADOS (RE-INSERIDOS AQUI) ---
const String _paoIntegralUrl =
    'https://placehold.co/600x400/8B4513/FFFFFF?text=P%C3%A3o+Integral';
const String _leiteUrl =
    'https://placehold.co/600x400/ADD8E6/000000?text=Leite+Desnatado';
const String _frangoUrl =
    'https://placehold.co/600x400/FFA07A/000000?text=Frango+Assado';
const String _mangaUrl =
    'https://placehold.co/600x400/FFD700/000000?text=Manga+Tommy';

final List<FoodListing> mockListings = [
  FoodListing(
    id: 1,
    title: 'Pão Integral',
    statusProximidadeVencimento: 'próximo',
    description: 'Pacote lacrado, validade próxima.',
    quantity: '2 pacotes',
    expiryDate: DateTime.now().add(const Duration(days: 1)),
    contactInfo: '5511987654321',
    imageUrl: _paoIntegralUrl,
    isMockUserOwner: true,
  ),
  FoodListing(
    id: 2,
    title: 'Leite Desnatado',
    statusProximidadeVencimento: 'hoje',
    description: 'Caixa de Leite Desnatado.',
    quantity: '1 litro',
    expiryDate: DateTime.now(),
    contactInfo: '5511987654321',
    imageUrl: _leiteUrl,
    isMockUserOwner: false,
  ),
  FoodListing(
    id: 3,
    title: 'Frango Assado',
    statusProximidadeVencimento: 'normal',
    description: 'Metade de um frango assado.',
    quantity: 'Meio frango',
    expiryDate: DateTime.now().add(const Duration(days: 5)),
    contactInfo: '5511987654321',
    imageUrl: _frangoUrl,
    isMockUserOwner: true,
  ),
  FoodListing(
    id: 4,
    title: 'Manga Tommy',
    statusProximidadeVencimento: 'normal',
    description: 'Três mangas maduras.',
    quantity: '3 unidades',
    expiryDate: DateTime.now().add(const Duration(days: 3)),
    contactInfo: '5511987654321',
    imageUrl: _mangaUrl,
    isMockUserOwner: false,
  ),
];
