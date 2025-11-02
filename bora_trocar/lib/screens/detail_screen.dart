import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/food_listing.dart';
import '../services/ads_service.dart';
import '../theme/app_theme.dart';
import 'new_ad_page.dart'; // Para navegação de Edição

class DetailScreen extends StatelessWidget {
  final FoodListing listing;
  // Apenas para fins de simulação de permissão: 
  // Em um app real, verificaríamos o userId do anúncio.
  final bool isUserOwner; 

  const DetailScreen({
    super.key, 
    required this.listing,
    this.isUserOwner = false, // Assumimos true para testar os botões de edição/exclusão
  });

  // --- Lógica de Formatação ---
  String _formatExpiry(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Vence HOJE';
    if (difference == 1) return 'Vence AMANHÃ';
    if (difference < 0) return 'VENCIDO!';
    
    return 'Vence em $difference dias';
  }

  // --- Ação de Contato ---
  Future<void> _launchWhatsApp(BuildContext context, String contact) async {
    final uri = Uri.parse(
      'https://wa.me/$contact?text=Olá! Vi o seu anúncio de ${listing.title} no Bora Trocar!. Ainda está disponível?',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  // --- Ação de Exclusão (RF04) ---
  Future<void> _confirmAndDelete(BuildContext context) async {
    final adsService = Provider.of<AdsService>(context, listen: false);

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o anúncio "${listing.title}"? Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Excluir', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      adsService.deleteListing(listing.id);
      // Navega de volta para a tela anterior
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anúncio "${listing.title}" excluído com sucesso!')),
      );
    }
  }
  
// --- Ação de Edição (RF03) ---
  void _editListing(BuildContext context) {
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (_) => NewAdPage(listingToEdit: listing), 
       ),
     );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        backgroundColor: AppTheme.primaryColor, // Usando AppTheme
        foregroundColor: Colors.white,
        
        // Ações de gerenciamento (Editar/Excluir) aparecem na AppBar
        actions: isUserOwner ? [
          // Botão de Editar (RF03)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editListing(context),
          ),
          // Botão de Excluir (RF04)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmAndDelete(context),
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Imagem (Placeholder/NetworkImage) ---
            Image.network(
              listing.imageUrl ?? '', 
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              // Mantido o errorBuilder para placeholder
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: AppTheme.imagePlaceholder,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // --- Título e Status de Validade ---
            Text(listing.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Container( // Contêiner para estilizar o status de validade
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _formatExpiry(listing.expiryDate).contains('HOJE') ? AppTheme.alertCriticalBackground : AppTheme.alertWarningBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatExpiry(listing.expiryDate),
                style: TextStyle(
                  color: _formatExpiry(listing.expiryDate).contains('HOJE') ? AppTheme.alertCritical : AppTheme.alertWarning,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            // --- Quantidade (Campo que estava faltando antes) ---
            const Text('Quantidade:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(listing.quantity), 
            const SizedBox(height: 20),
            
            const SizedBox(height: 20),
            
            // --- Descrição ---
            const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(listing.description), 
            const SizedBox(height: 30),
            
            // --- Botão de Contato (Para usuários NÃO-DONOS) ---
            if (!isUserOwner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context, listing.contactInfo),
                  icon: const Icon(Icons.chat),
                  label: const Text('Entrar em contato via WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}