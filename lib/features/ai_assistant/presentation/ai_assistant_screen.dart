import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
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
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    ref.read(chatMessagesProvider.notifier).addMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 300,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(aiTypingProvider);

    // auto-scroll on new message
    ref.listen(chatMessagesProvider, (prev, next) => _scrollToBottom());
    ref.listen(aiTypingProvider, (prev, next) => _scrollToBottom());

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
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CampusChain AI', style: AppTypography.headlineMedium),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 900.ms),
                        const SizedBox(width: 6),
                        AnimatedSwitcher(
                          duration: 300.ms,
                          child: Text(
                            isTyping ? 'Thinking...' : 'Online — Your smart assistant',
                            key: ValueKey(isTyping),
                            style: AppTypography.labelSmall.copyWith(
                              color: isTyping ? AppColors.accentPrimary : AppColors.success,
                            ),
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
              itemCount: messages.length + (isTyping ? 1 : 0) + (messages.length <= 1 ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator
                if (isTyping && index == messages.length) {
                  return const TypingIndicator()
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.1);
                }

                // Suggested questions
                if (index == messages.length + (isTyping ? 1 : 0)) {
                  return _SuggestedQuestions(
                    onTap: (q) {
                      HapticFeedback.selectionClick();
                      _textController.text = q;
                      _sendMessage();
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
                }

                final msg = messages[index];
                return _ChatBubble(message: msg, index: index)
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.06)
                    .slideX(begin: msg.isUser ? 0.04 : -0.04);
              },
            ),
          ),

          // ─── Input Bar ───
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AnimatedContainer(
              duration: 250.ms,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.accentPrimary.withValues(alpha: 0.5)
                      : AppColors.glassBorder,
                  width: _isFocused ? 1.5 : 1.0,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.accentPrimary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            style: AppTypography.bodyMedium,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Ask CampusChain AI...',
                              hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: AnimatedContainer(
                            duration: 200.ms,
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: _textController.text.isNotEmpty
                                  ? AppColors.gradientPrimary
                                  : null,
                              color: _textController.text.isEmpty
                                  ? AppColors.glassFill
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.send_rounded,
                              color: _textController.text.isNotEmpty
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
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
  final int index;

  const _ChatBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppColors.gradientPrimary : null,
          color: message.isUser ? null : AppColors.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          border: message.isUser ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
            return _SuggestionChip(label: q, onTap: () => onTap(q));
          }).toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 120.ms);
    _scale = Tween(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelSmall.copyWith(color: AppColors.accentPrimary),
          ),
        ),
      ),
    );
  }
}
