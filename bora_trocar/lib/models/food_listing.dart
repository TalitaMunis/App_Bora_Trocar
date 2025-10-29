// Arquivo: lib/models/food_listing.dart

// Modelo para representar um anúncio de alimento
class FoodListing {
  final String id;
  final String title; // Mantido como 'title'
  final String? imageUrl; // Adicionado para futura implementação de imagem de rede
  final String statusProximidadeVencimento;
  
  // CAMPOS ADICIONADOS:
  final DateTime expiryDate; // <--- CAMPO QUE FALTAVA (DateTime)
  final String description;
  final String contactInfo; // Contato para o WhatsApp

  FoodListing({
    required this.id,
    required this.title,
    this.imageUrl, // Torna opcional no construtor
    required this.statusProximidadeVencimento,
    // Novos campos
    required this.expiryDate,
    required this.description,
    required this.contactInfo,
  });
}

// Lista de Mock de Anúncios para preencher a tela
final List<FoodListing> mockListings = [
  FoodListing(
    id: '1',  
    title: 'Pão Integral', 
    imageUrl: null, 
    statusProximidadeVencimento: 'Vence amanhã',
    // Dados de Detalhe Mockados
    expiryDate: DateTime.now().add(const Duration(days: 1)),
    description: 'Pão de forma integral, pacote lacrado. Ideal para sanduíches saudáveis ou torradas. Pego 2 pacotes por engano.',
    contactInfo: '5511987654321', // Exemplo de número de WhatsApp (código do país + DDD + número)
  ),
  FoodListing(
    id: '2',  
    title: 'Leite Desnatado', 
    imageUrl: null,  
    statusProximidadeVencimento: 'Vence hoje',
    // Dados de Detalhe Mockados
    expiryDate: DateTime.now(),
    description: 'Caixa de Leite Desnatado. Validade expira hoje, mas está lacrada e refrigerada.',
    contactInfo: '5511987654321', 
  ),
  FoodListing(
    id: '3',  
    title: 'Pão Integral', 
    imageUrl: null,  
    statusProximidadeVencimento: '500m de você',
    // Dados de Detalhe Mockados
    expiryDate: DateTime.now().add(const Duration(days: 5)),
    description: 'Metade de um pacote de pão integral, aberto ontem, guardado em pote hermético. Está em perfeito estado!',
    contactInfo: '5511987654321',
  ),
  FoodListing(
    id: '4',  
    title: 'Pêra', 
    imageUrl: null,  
    statusProximidadeVencimento: '1.2km de você',
    // Dados de Detalhe Mockados
    expiryDate: DateTime.now().add(const Duration(days: 3)),
    description: 'Três pêras maduras, frescas. Não consigo comer todas a tempo.',
    contactInfo: '5511987654321',
  ),
];