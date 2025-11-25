import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ Necessário para base64Decode
import 'dart:typed_data'; // ✅ Necessário para Image.memory
import '../models/food_listing.dart';
import '../theme/app_theme.dart';

class SimpleListingCard extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback? onTap;

  const SimpleListingCard({super.key, required this.listing, this.onTap});

  Widget _buildStatusChip(String status) {
    // ... (lógica do chip omitida)
    Color chipColor;
    Color textColor;

    // Lógica de cores usando o AppTheme
    if (status.contains('hoje')) {
      chipColor = AppTheme.alertCriticalBackground;
      textColor = AppTheme.alertCritical;
    } else if (status.contains('amanha')) {
      chipColor = AppTheme.alertWarningBackground;
      textColor = AppTheme.alertWarning;
    } else {
      // Proximidade (Ex: 500m de você)
      chipColor = AppTheme.proximityBackground;
      textColor = AppTheme.proximityText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 LÓGICA DE EXIBIÇÃO DA IMAGEM
    Uint8List? imageBytes;
    if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty) {
      try {
        // Tenta decodificar a string Base64
        imageBytes = base64Decode(listing.imageUrl!);
      } catch (e) {
        imageBytes = null;
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- CONTAINER DA IMAGEM/PLACEHOLDER ---
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.imagePlaceholder,
                  ),
                  child: imageBytes != null
                      ? Image.memory(
                          // ✅ CORREÇÃO: Usa Image.memory para exibir o Base64
                          imageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                      : const Center(
                          // Placeholder padrão
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                // --- INFORMAÇÕES ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Chip de Status
                      _buildStatusChip(listing.statusProximidadeVencimento),
                    ],
                  ),
                ),

                // Ícone para Detalhes
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        // Divisor
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
