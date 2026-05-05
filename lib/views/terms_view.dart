import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import 'sleep_view.dart';

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
  bool _accepted = false;

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acceptedTerms', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SleepView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Icon(Icons.shield, size: 64, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              Text(
                "Data Privacy\n& Terms of Use",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      "Welcome to Sleep Tracker.\n\n"
                      "To ensure a calm and secure bedtime experience, we strictly follow LGPD data protection guidelines.\n\n"
                      "1. We only store data necessary to calculate your sleep duration.\n"
                      "2. Your data is not sold to third parties.\n"
                      "3. You have full control over your local history.\n\n"
                      "By checking the box below, you agree to these terms and allow the application to track your sleep sessions.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _accepted = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "I accept the Terms of Use and Privacy Policy.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "Continue",
                icon: Icons.arrow_forward,
                color: _accepted ? Theme.of(context).primaryColor : Colors.grey[700],
                onPressed: () {
                  if (_accepted) {
                    _saveAndContinue();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You must accept the terms to continue."),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
