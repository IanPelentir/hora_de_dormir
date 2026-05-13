import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sleep_view.dart';

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Detecta quando o usuário rolou até o final do texto
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        if (!_hasScrolledToBottom) {
          setState(() => _hasScrolledToBottom = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Termos de Privacidade"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ✅ Ícone com glow
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigoAccent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 64,
                    color: Colors.indigoAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Proteção dos seus dados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Leia os termos antes de continuar",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Container do texto com indicador de scroll
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle("📋 Conformidade com a LGPD"),
                            Text(
                              "Lei Geral de Proteção de Dados Pessoais (Lei nº 13.709/2018)",
                              style: TextStyle(fontSize: 12, color: Colors.white38),
                            ),
                            SizedBox(height: 16),

                            _SectionTitle("1. Dados Coletados"),
                            _BulletPoint("Identificação: Seu ID de usuário único vinculado à sua conta."),
                            _BulletPoint("Dados de Sono: Horários de início e término das sessões, bem como a duração calculada."),
                            _BulletPoint("E-mail: Utilizado exclusivamente para autenticação."),
                            SizedBox(height: 16),

                            _SectionTitle("2. Finalidade"),
                            _BulletPoint("Gerar seu histórico pessoal de sono."),
                            _BulletPoint("Fornecer feedbacks personalizados sobre qualidade do sono."),
                            _BulletPoint("Exibir gráficos e estatísticas para acompanhamento."),
                            SizedBox(height: 16),

                            _SectionTitle("3. Armazenamento"),
                            _BulletPoint("Seus dados são armazenados de forma segura no Google Cloud Firestore."),
                            _BulletPoint("Cada usuário acessa apenas seus próprios dados (isolamento por UID)."),
                            SizedBox(height: 16),

                            _SectionTitle("4. Compartilhamento"),
                            _BulletPoint("Seus dados NÃO são compartilhados com terceiros."),
                            _BulletPoint("Não realizamos venda ou monetização de dados pessoais."),
                            SizedBox(height: 16),

                            _SectionTitle("5. Seus Direitos"),
                            _BulletPoint("Acesso: Visualize todos os seus dados a qualquer momento."),
                            _BulletPoint("Exclusão: Solicite a remoção completa dos seus dados."),
                            _BulletPoint("Portabilidade: Exporte seus dados quando desejar."),
                            _BulletPoint("Revogação: Retire seu consentimento a qualquer momento."),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // ✅ Indicador de "role para baixo" que desaparece
                    if (!_hasScrolledToBottom)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0D1B2A).withOpacity(0.9),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  "Role para ler tudo",
                                  style: TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Botão que fica habilitado após rolar
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _hasScrolledToBottom ? 1.0 : 0.5,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasScrolledToBottom
                          ? Colors.indigoAccent
                          : Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: _hasScrolledToBottom ? 4 : 0,
                      shadowColor: Colors.indigoAccent.withOpacity(0.4),
                    ),
                    onPressed: (auth.isLoading || !_hasScrolledToBottom)
                        ? null
                        : () async {
                            await auth.acceptTerms();

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    SizedBox(width: 12),
                                    Text("Termos aceitos com sucesso!"),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const SleepView(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _hasScrolledToBottom
                                ? "LI E CONCORDO COM OS TERMOS"
                                : "LEIA OS TERMOS ACIMA",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget helper para títulos de seção
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Widget helper para bullet points
class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: Colors.indigoAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}