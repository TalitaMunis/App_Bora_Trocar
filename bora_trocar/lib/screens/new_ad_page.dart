import 'package:flutter/material.dart';

// Tela de Novo Anúncio (RF01) - (image_ffb176.jpg)
class NewAdPage extends StatelessWidget {
  const NewAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Note que esta tela tem seu próprio Scaffold,
    // pois é "empurrada" (push) sobre a navegação principal.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Anúncio (RF01)'),
      ),
      body: const Center(
        child: Text('Aqui ficará o formulário do anúncio.'),
      ),
    );
  }
}
