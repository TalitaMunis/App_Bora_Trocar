import 'package:flutter/material.dart';
import 'package:bora_trocar/models/food_listing.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final FoodListing listing;

  const DetailScreen({super.key, required this.listing});

  String _formatExpiry(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference == 0) return 'Vence HOJE';
    if (difference == 1) return 'Vence AMANHÃ';
    if (difference < 0) return 'VENCIDO!';
    return 'Vence em $difference dias';
  }

  Future<void> _launchWhatsApp(BuildContext context, String contact) async {
    final uri = Uri.parse(
      'https://wa.me/$contact?text=Olá! Vi o seu anúncio de ${listing.title} no Bora Trocar!. Ainda está disponível?',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ✅ Evita erro se o widget foi desmontado
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              listing.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(listing.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              _formatExpiry(listing.expiryDate),
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(listing.description),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(context, listing.contactInfo),
              icon: const Icon(Icons.chat),
              label: const Text('Entrar em contato via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
