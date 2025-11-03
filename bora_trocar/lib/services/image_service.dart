import 'dart:math';

/// Serviço que simula a escolha e o upload de uma imagem
/// Retorna uma URL de placeholder para simular o Firebase Storage.
class ImageService {
  final List<String> placeholderTexts = [
    'Pão',
    'Fruta',
    'Doce',
    'Vegetal',
    'Carne',
    'Laticínio',
    'Bebida',
  ];
  final List<String> placeholderColors = [
    '50C4FF',
    'FFD700',
    'FF5733',
    '4CAF50',
    '800080',
    'FF6347',
    '00CED1',
  ];
  final Random _random = Random();

  /// Simula a abertura do seletor de arquivos e o upload.
  /// Retorna a URL da imagem (simulada) que foi "selecionada".
  Future<String> pickAndUploadImage() async {
    // Simula o tempo de espera para o usuário escolher a imagem
    await Future.delayed(const Duration(milliseconds: 700));

    // Lógica para gerar uma URL de placeholder única e aleatória
    final textIndex = _random.nextInt(placeholderTexts.length);
    final colorIndex = _random.nextInt(placeholderColors.length);

    final text = placeholderTexts[textIndex];
    final color = placeholderColors[colorIndex];

    // URL de placeholder (simula a URL pública do Storage)
    final imageUrl = 'https://placehold.co/600x400/$color/white?text=$text';

    return imageUrl;
  }

  /// Simula a remoção da imagem no Storage.
  Future<void> removeImage(String url) async {
    // ❌ A instrução 'print' foi removida para eliminar o aviso de produção.
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
