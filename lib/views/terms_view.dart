import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_view.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Termos LGPD")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Aqui você coloca os termos de uso e LGPD do app...",
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await auth.acceptTerms();

                if (!context.mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthView()),
                );
              },
              child: const Text("Aceito os termos"),
            ),
          ],
        ),
      ),
    );
  }
}