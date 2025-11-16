import 'package:flutter/material.dart';
import '../models/food_listing.dart'; 
import '../theme/app_theme.dart'; // Importa seu arquivo de tema

class SimpleListingCard extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback? onTap; // ✅ O callback está aqui
  
  // ✅ ATENÇÃO: Corrigido o construtor para aceitar 'onTap' corretamente
  const SimpleListingCard({
    super.key, 
    required this.listing, 
    this.onTap,
  });
  

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    
    // Lógica de cores usando o AppTheme
    if (status.contains('hoje')) {
      chipColor = AppTheme.alertCriticalBackground;
      textColor = AppTheme.alertCritical;
    } else if (status.contains('amanhã')) {
      chipColor = AppTheme.alertWarningBackground;
      textColor = AppTheme.alertWarning;
    } else { // Proximidade (Ex: 500m de você)
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
    return Column(
      children: [
        // 🎯 INKWELL ADICIONADO AQUI para capturar o toque em toda a área
        InkWell(
          onTap: onTap, // Usa o callback passado pela HomePage/AdsPage
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Placeholder Fixo
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.imagePlaceholder, 
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined, 
                      color: Colors.grey,
                      size: 30, 
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
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

                // Ícone para Detalhes (Continua apenas como visual)
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