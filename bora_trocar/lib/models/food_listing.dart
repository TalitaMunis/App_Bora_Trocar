// Este é um placeholder para seu modelo de dados (RF01)
// Vamos começar a construí-lo.
class FoodListing {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime expiryDate; // Data de validade
  final String quantity; // ex: "2kg" ou "5 unidades"
  final String imageUrl;
  final String contactInfo;
  final String location; // Simplificado por enquanto
  final String userId; // ID do dono do anúncio

  FoodListing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.expiryDate,
    required this.quantity,
    required this.imageUrl,
    required this.contactInfo,
    required this.location,
    required this.userId,
  });

  // No futuro, adicionaremos métodos aqui:
  // - fromJson(Map<String, dynamic> json) para ler do Firebase
  // - toJson() para escrever no Firebase
}
