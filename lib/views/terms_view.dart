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
      appBar: AppBar(
        title: const Text("Termos de Privacidade"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Impede voltar sem aceitar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.gavel_rounded, size: 64, color: Colors.indigoAccent),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    "Conformidade com a LGPD (Lei 13.709/2018)\n\n"
                    "Para o funcionamento do Sleep Tracker, coletamos os seguintes dados:\n\n"
                    "1. Identificação: Seu ID de usuário único vinculado à sua conta.\n"
                    "2. Dados de Sono: Horários de início e término das sessões, bem como a duração calculada.\n\n"
                    "Finalidade: Os dados são coletados exclusivamente para gerar seu histórico de sono e feedbacks personalizados.\n\n"
                    "Privacidade: Seus dados são armazenados de forma segura no Google Cloud Firestore e não são compartilhados com terceiros.\n\n"
                    "Exclusão: Você possui o direito de solicitar a exclusão de seus dados a qualquer momento através das configurações do app.",
                    style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                // ✅ Chama a lógica no Provider para salvar no Firebase o aceite
                await auth.acceptTerms();

                if (!context.mounted) return;

                // ✅ Após aceitar, vai para a AuthView (ou HomeView se já logado)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthView()),
                );
              },
              child: const Text(
                "LI E CONCORDO COM OS TERMOS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}