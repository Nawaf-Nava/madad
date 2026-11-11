import 'package:flutter/material.dart';
import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messages = <Map<String, dynamic>>[];
  final inputC = TextEditingController();

  @override
  void dispose() {
    inputC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('helpSupport'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: MadadNotice(
              message: l10n.choose(
                ar: 'هذه معاينة محلية؛ لا يتم إرسال الرسائل إلى فريق دعم.',
                en: 'This is a local preview; messages are not delivered to a support team.',
              ),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? MadadEmptyState(
                    icon: Icons.forum_outlined,
                    title: l10n.choose(ar: 'لا توجد رسائل', en: 'No messages'),
                    message: l10n.choose(
                      ar: 'ابدأ معاينة محلية للمحادثة. لن تصل الرسائل إلى جهة خارجية.',
                      en: 'Start a local conversation preview. Messages are not sent externally.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['isMe'] as bool;
                      return Align(
                        alignment: isMe
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? MadadColors.orangeSurface
                                : MadadColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: MadadColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message['text'] as String,
                                  style: const TextStyle(
                                      color: MadadColors.textPrimary,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(message['time'] as String,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: MadadColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: MadadColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputC,
                    decoration: InputDecoration(
                        hintText: l10n.choose(
                            ar: 'اكتب رسالة معاينة...',
                            en: 'Write a preview message...')),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      const Icon(Icons.send_rounded, color: MadadColors.orange),
                  onPressed: () {
                    final text = inputC.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      messages.add({
                        'text': text,
                        'isMe': true,
                        'time': l10n.choose(ar: 'الآن', en: 'Now')
                      });
                      inputC.clear();
                    });
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        setState(() {
                          messages.add({
                            'text': l10n.choose(
                              ar: 'رد معاينة محلي؛ لم يُرسل استفسارك إلى فريق دعم.',
                              en: 'Local preview reply; your message was not sent to support.',
                            ),
                            'isMe': false,
                            'time': l10n.choose(ar: 'الآن', en: 'Now'),
                          });
                        });
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
