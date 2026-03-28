import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/data/mock_data.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider.notifier).addMessage(text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return SafeArea(
      child: Column(
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CampusChain AI', style: AppTypography.headlineMedium),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online — Your smart assistant',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 16),

          // ─── Messages ───
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: messages.length +
                  (messages.isEmpty ? 0 : 1), // +1 for suggestions
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  // Suggested questions at the bottom
                  if (messages.length <= 1) {
                    return _SuggestedQuestions(
                      onTap: (q) {
                        _textController.text = q;
                        _sendMessage();
                      },
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
                  }
                  return const SizedBox();
                }

                final msg = messages[index];
                return _ChatBubble(message: msg)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.05);
              },
            ),
          ),

          // ─── Suggested Questions (initial) ───
          if (messages.length <= 1) ...[
            const SizedBox(height: 8),
          ],

          // ─── Input ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: AppTypography.bodyMedium,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Ask CampusChain AI...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? AppColors.gradientPrimary
              : null,
          color: message.isUser ? null : AppColors.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          message.content,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SuggestedQuestions extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _SuggestedQuestions({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Suggested questions:', style: AppTypography.labelSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MockData.aiSuggestedQuestions.map((q) {
            return GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  q,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
