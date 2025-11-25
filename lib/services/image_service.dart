import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Pacote para selecionar imagem

/// Serviço que lida com a seleção de imagens e conversão para Base64.
/// NOTA: O método pickAndEncode simula o processo de upload real para o ambiente local.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Abre o seletor de imagens, lê o arquivo e o converte para string Base64.
  /// Retorna a string Base64 (que é salva no Hive).
  Future<String?> pickAndEncodeImage() async {
    // Permite ao usuário escolher uma imagem da galeria
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      // Lê o conteúdo do arquivo como bytes
      final Uint8List bytes = await pickedFile.readAsBytes();

      // Converte os bytes para uma string Base64
      final String base64Image = base64Encode(bytes);

      return base64Image;
    }
    return null;
  }

  /// Simula a remoção da imagem (operação de housekeeping).
  Future<void> removeImage(String base64String) async {
    // Em um cenário real, notificaríamos o servidor para deletar.
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
