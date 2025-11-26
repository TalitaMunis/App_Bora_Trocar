import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/food_listing.dart';
import '../services/ads_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'new_ad_page.dart';
import '../utils/auth_check.dart';

// Conversão para StatefulWidget para gerenciar o nome do anunciante
class DetailScreen extends StatefulWidget {
  final FoodListing listing;
  final bool isUserOwner;

  const DetailScreen({
    super.key,
    required this.listing,
    this.isUserOwner = false,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Estado para armazenar o nome do anunciante
  String _advertiserName = 'Carregando...';

  @override
  void initState() {
    super.initState();
    // Inicia a busca do nome do anunciante
    _loadAdvertiserName();
  }

  // Busca o nome do anunciante pelo creatorUserId
  Future<void> _loadAdvertiserName() async {
    // Usa o creatorUserId do anúncio
    final creatorId = widget.listing.creatorUserId;

    // 2. Busca o perfil do UserService
    final userService = Provider.of<UserService>(context, listen: false);

    // Se o usuário for o dono (ex: editando seu próprio anúncio), usa o nome logado
    if (widget.isUserOwner) {
      if (mounted) {
        setState(() {
          _advertiserName = userService.currentUser.name;
        });
      }
      return;
    }

    // 3. Busca o perfil pelo ID do criador
    final advertiser = userService.getUserById(creatorId);

    if (advertiser != null) {
      if (mounted) {
        setState(() {
          _advertiserName = advertiser.name;
        });
      }
    } else {
      // Mock fallback: Se o usuário foi deletado ou não foi encontrado
      if (mounted) {
        setState(() {
          _advertiserName = 'Anunciante Não Encontrado';
        });
      }
    }
  }

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
      'https://wa.me/$contact?text=Olá! Vi o seu anúncio de ${widget.listing.title} no Bora Trocar!. Ainda está disponível?',
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
        content: Text(
          'Tem certeza que deseja excluir o anúncio "${widget.listing.title}"? Esta ação é irreversível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Excluir',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      adsService.deleteListing(widget.listing.id);

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anúncio "${widget.listing.title}" excluído com sucesso!',
          ),
        ),
      );
    }
  }

  // --- Ação de Edição (RF03) ---
  void _editListing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewAdPage(listingToEdit: widget.listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = widget.listing; // Usar uma variável local para simplificar

    // Tenta decodificar a imagem Base64 para exibição
    Uint8List? imageBytes;
    if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty) {
      try {
        imageBytes = base64Decode(listing.imageUrl!);
      } catch (e) {
        // Ignora erro de decodificação se for uma URL antiga ou inválida
        imageBytes = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,

        actions: widget.isUserOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editListing(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmAndDelete(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Imagem (Exibição Condicional) ---
            Container(
              height: 250,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.imagePlaceholder,
              ),
              child: imageBytes != null
                  ? Image.memory(
                      //Usa Image.memory para exibir Base64
                      imageBytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.red.shade600,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // --- Título ---
            Text(widget.listing.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),

            // Nome do anunciante (exibido no detalhamento)
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  _advertiserName, // exibe o nome do anunciante
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- Status de Validade ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    _formatExpiry(widget.listing.expiryDate).contains('VENCIDO')
                    ? AppTheme.alertCriticalBackground
                    : AppTheme.alertWarningBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatExpiry(widget.listing.expiryDate),
                style: TextStyle(
                  color:
                      _formatExpiry(
                        widget.listing.expiryDate,
                      ).contains('VENCIDO')
                      ? AppTheme.alertCritical
                      : AppTheme.alertWarning,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            //LOCALIZAÇÃO DO ANÚNCIO
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  'Local: ${widget.listing.location}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- Categoria ---
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categoria: ${widget.listing.category ?? 'Não Definida'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // --- Quantidade ---
            const Text(
              'Quantidade:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(widget.listing.quantity),
            const SizedBox(height: 20),

            // --- Descrição ---
            const Text(
              'Descrição:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(widget.listing.description),
            const SizedBox(height: 30),

            // --- Botão de Contato ---
            if (!widget.isUserOwner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (checkAuthAndNavigate(context)) {
                      _launchWhatsApp(context, widget.listing.contactInfo);
                    }
                  },
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
