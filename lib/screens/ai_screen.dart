import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../models/ai_message.dart';
import '../providers/ai_provider.dart';
import '../providers/translation_provider.dart';
import '../providers/task_provider.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({Key? key}) : super(key: key);

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isNotEmpty) {
      _messageController.clear();
      await context.read<AiProvider>().sendMessage(text);
      // Realtime streams in TaskProvider will handle updates automatically
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: const JarvisTopbar(
        title: 'JARVIS AI ASSISTANT',
      ),
      body: Consumer<AiProvider>(
        builder: (context, aiProvider, child) {
          // If no messages, add initial context
          if (aiProvider.messages.isEmpty) {
            Future.microtask(() {
              // Add mock conversation from the image
              // Normally this would be handled differently, but we'll mock it for the UI
            });
          }

          return isDesktop ? _buildDesktopLayout(aiProvider) : _buildMobileLayout(aiProvider);
        },
      ),
    );
  }

  Widget _buildDesktopLayout(AiProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: bgSecondary,
                borderRadius: BorderRadius.circular(BorderValues.md),
                border: Border.all(color: goldLine),
              ),
              child: Column(
                children: [
                  _buildDesktopChatHeader(),
                  const Divider(color: goldLine, height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(Spacing.lg),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(provider.messages[index]);
                      },
                    ),
                  ),
                  if (provider.isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: gold)),
                          const SizedBox(width: 12),
                          Text('JARVIS is processing...', style: TextStyle(color: gold.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  _buildChatInput(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.xl),
          Expanded(
            flex: 1,
            child: _buildDesktopSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(AiProvider provider) {
    return Column(
      children: [
        _buildMobileChatHeader(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(Spacing.md),
            itemCount: provider.messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(provider.messages[index], isMobile: true);
            },
          ),
        ),
        if (provider.isProcessing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: gold)),
                const SizedBox(width: 12),
                Text('JARVIS is thinking...', style: TextStyle(color: gold.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
        _buildMobileQuickAsk(),
        _buildChatInput(context, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopChatHeader() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          const AiOrbSmall(size: 30),
          const SizedBox(width: Spacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JARVIS INTELLIGENCE ASSISTANT', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 14)),
              Row(
                children: [
                  Icon(Icons.circle, color: incomeLight, size: 8),
                  const SizedBox(width: 4),
                  const Text('ACTIVE', style: TextStyle(color: incomeLight, fontSize: 10)),
                ],
              ),
            ],
          ),
          const Spacer(),
          JarvisChip(label: 'Context: All Projects', type: ChipType.ok),
          const SizedBox(width: Spacing.sm),
          JarvisChip(label: 'History: Last 30d', type: ChipType.warn),
        ],
      ),
    );
  }

  Widget _buildMobileChatHeader() {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: goldLine)),
      ),
      child: Row(
        children: [
          const AiOrbSmall(size: 40),
          const SizedBox(width: Spacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JARVIS', style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Icon(Icons.circle, color: incomeLight, size: 8),
                  const SizedBox(width: 4),
                  const Text('ONLINE', style: TextStyle(color: incomeLight, fontSize: 10)),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: textDim),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage message, {bool isMobile = false}) {
    final isUser = message.sender == MessageSender.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 40.0 : 0.0,
              right: isUser ? 0.0 : 40.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: isUser ? bgTertiary : Colors.transparent,
                border: Border.all(color: goldLine, width: isUser ? 0 : 0.5),
                borderRadius: BorderRadius.circular(BorderValues.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isUser ? 'YOU' : 'JARVIS', style: TextStyle(color: isUser ? textDim : goldLight, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: Spacing.md),
                      Text(message.timestamp.toString().substring(11, 16), style: const TextStyle(color: textDim, fontSize: 10)), // Simple time
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    message.content,
                    style: TextStyle(color: isUser ? textPrimary : textDim, fontSize: isMobile ? 13 : 14, height: 1.5),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: Spacing.md),
                    const Divider(color: goldLine, height: 1),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        _MessageActionButton(
                          icon: Icons.save_alt,
                          label: 'STORE TRANSLATION',
                          onTap: () {
                            context.read<TranslationProvider>().addTranslation(
                              'Original text unavailable from history',
                              message.content,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Translation stored in AI VAULT.')),
                            );
                          },
                        ),
                        const SizedBox(width: Spacing.md),
                        _MessageActionButton(
                          icon: Icons.copy,
                          label: 'COPY',
                          onTap: () {
                            // Copy logic
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'CONTEXT LOADED'),
        const SizedBox(height: Spacing.md),
        _buildContextChip('All 3 Projects', incomeLight),
        const SizedBox(height: Spacing.xs),
        _buildContextChip('8 Team Members', gold),
        const SizedBox(height: Spacing.xs),
        _buildContextChip('Last 30 days history', const Color(0xFF00BFFF)),
        
        const SizedBox(height: Spacing.xl),
        SectionTitle(title: 'SUGGESTED'),
        const SizedBox(height: Spacing.md),
        _buildSuggestedAction('Generate weekly summary', Icons.summarize),
        const SizedBox(height: Spacing.sm),
        _buildSuggestedAction('Show all blocked tasks', Icons.block, isWarning: true),
        const SizedBox(height: Spacing.sm),
        _buildSuggestedAction('Plan my next 3 days', Icons.calendar_today),
        const SizedBox(height: Spacing.sm),
        _buildSuggestedAction('Who is overloaded?', Icons.people),
      ],
    );
  }

  Widget _buildContextChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: color.withOpacity(0.05),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSuggestedAction(String text, IconData icon, {bool isWarning = false}) {
    return InkWell(
      onTap: () {
        _sendMessage(text);
      },
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: bgTertiary,
          border: Border.all(color: isWarning ? warnColor.withOpacity(0.3) : goldLine),
          borderRadius: BorderRadius.circular(BorderValues.sm),
        ),
        child: Row(
          children: [
            Icon(icon, color: isWarning ? warnColor : gold, size: 14),
            const SizedBox(width: Spacing.md),
            Expanded(child: Text(text, style: const TextStyle(color: textDim, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileQuickAsk() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('QUICK ASK', style: TextStyle(color: textDim, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: Spacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMobileQuickChip('My tasks today', Icons.task_alt),
                const SizedBox(width: Spacing.sm),
                _buildMobileQuickChip('What\'s at risk?', Icons.warning_amber_rounded, isWarning: true),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ),
    );
  }

  Widget _buildMobileQuickChip(String text, IconData icon, {bool isWarning = false}) {
    return InkWell(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isWarning ? warnColor.withOpacity(0.5) : goldLine),
          borderRadius: BorderRadius.circular(BorderValues.sm),
          color: isWarning ? warnColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isWarning ? warnColor : gold, size: 14),
            const SizedBox(width: Spacing.xs),
            Text(text, style: TextStyle(color: isWarning ? warnColor : textPrimary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, {bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: goldLine, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: isMobile ? 'Ask JARVIS anything...' : 'Ask JARVIS anything - tasks, risks, team status, reminders...',
                hintStyle: const TextStyle(color: textDim, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BorderValues.sm),
                  borderSide: const BorderSide(color: goldLine),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BorderValues.sm),
                  borderSide: const BorderSide(color: goldLine),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BorderValues.sm),
                  borderSide: const BorderSide(color: gold),
                ),
                filled: true,
                fillColor: bgTertiary,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: Spacing.md),
          ElevatedButton(
            onPressed: () => _sendMessage(_messageController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BorderValues.sm)),
            ),
            child: const Text('SEND', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: Spacing.sm),
          IconButton(
            icon: const Icon(Icons.mic, color: textDim),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice input activated.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MessageActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: gold, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: gold,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
