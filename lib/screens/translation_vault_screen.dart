// lib/screens/translation_vault_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/translation_provider.dart';
import '../providers/ai_provider.dart';
import '../models/translation_model.dart';
import '../providers/jarvis_provider.dart';

class TranslationVaultScreen extends StatelessWidget {
  const TranslationVaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const JarvisTopbar(
        title: 'AI TRANSLATION VAULT',
      ),
      body: provider.translations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(isDesktop ? Spacing.xl : Spacing.lg),
              itemCount: provider.translations.length,
              itemBuilder: (context, index) {
                return _TranslationCard(translation: provider.translations[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.translate, size: 64, color: gold.withOpacity(0.2)),
          const SizedBox(height: Spacing.lg),
          Text(
            'VAULT IS EMPTY',
            style: GoogleFonts.orbitron(
              color: textDim,
              fontSize: 16,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          const Text(
            'Store translations from JARVIS AI to see them here.',
            style: TextStyle(color: textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TranslationCard extends StatefulWidget {
  final TranslationModel translation;
  const _TranslationCard({required this.translation});

  @override
  State<_TranslationCard> createState() => _TranslationCardState();
}

class _TranslationCardState extends State<_TranslationCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.translation.translatedText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: bgSecondary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STORED TRANSLATION',
                style: GoogleFonts.jetBrainsMono(
                  color: gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: gold, size: 18),
                    onPressed: () {
                      if (_isEditing) {
                        context.read<TranslationProvider>().updateTranslation(
                          widget.translation.id,
                          _controller.text,
                        );
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: dangerColor, size: 18),
                    onPressed: () => context.read<TranslationProvider>().deleteTranslation(widget.translation.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (_isEditing)
            TextField(
              controller: _controller,
              maxLines: null,
              style: const TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: bgTertiary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: goldLine)),
              ),
            )
          else
            Text(
              widget.translation.translatedText,
              style: GoogleFonts.jetBrainsMono(
                color: gold, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          const SizedBox(height: Spacing.lg),
          const Divider(color: goldLine, height: 1),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              _VaultActionButton(
                icon: Icons.refresh,
                label: 'RE-TRANSLATE',
                onTap: () {
                  final prompt = "Re-translate this text to ${widget.translation.targetLanguage}: ${_controller.text}";
                  context.read<AiProvider>().sendMessage(prompt);
                  
                  // Redirect to JARVIS (AiScreen) - Index 9
                  context.read<JarvisProvider>().setNavigationIndex(9);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-translation request sent to JARVIS.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VaultActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VaultActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: gold.withOpacity(0.1),
        foregroundColor: gold,
        side: const BorderSide(color: goldLine),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
