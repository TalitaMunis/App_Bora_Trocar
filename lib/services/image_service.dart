import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Serviço que lida com a seleção de imagens e conversão.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Lista de Mocks para simulação visual (usaremos apenas para fallback)
  final List<String> placeholderUrls = [
    'https://placehold.co/60x60/8B4513/FFFFFF?text=P%C3%A3o',
    'https://placehold.co/60x60/FFD700/000000?text=Fruta',
  ];

  /// Simula a abertura do seletor e retorna o arquivo XFile para manipulação.
  Future<XFile?> pickImageFile() async {
    return _picker.pickImage(source: ImageSource.gallery);
  }

  /// Converte o XFile para uma string Base64.
  Future<String?> encodeFileToBase64(XFile file) async {
    final Uint8List bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // Método que combina seleção e codificação para Base64
  /// Abre o seletor, obtém o arquivo e retorna a string Base64.
  Future<String?> pickAndEncodeImage() async {
    final file = await pickImageFile();
    if (file != null) {
      return encodeFileToBase64(file);
    }
    return null;
  }

  /// Simula a remoção da imagem.
  Future<void> removeImage(String base64String) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
