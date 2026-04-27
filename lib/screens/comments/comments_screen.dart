import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/gallery_detail/gallery_detail_bloc.dart';
import '../../blocs/gallery_detail/gallery_detail_event.dart';
import '../../core/l10n/s.dart';
import '../../models/gallery_comment.dart';
import '../../core/utils/eh_url_parser.dart';

class CommentsScreen extends StatelessWidget {
  final int gid;
  final String token;
  final List<GalleryComment> comments;

  const CommentsScreen({
    super.key,
    required this.gid,
    required this.token,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.comments(comments.length)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.author,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: comment.isUploader
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                      ),
                      if (comment.isUploader) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            s.uploaderBadge,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (comment.score != 0)
                        Text(
                          comment.score > 0
                              ? '+${comment.score}'
                              : '${comment.score}',
                          style: TextStyle(
                            fontSize: 12,
                            color: comment.score > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildCommentContent(context, comment.content),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(comment.postedAt),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          context.read<GalleryDetailBloc>().add(VoteComment(
                                gid: gid,
                                token: token,
                                commentId: comment.id,
                                isUpvote: true,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            comment.isVotedUp
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 14,
                            color: comment.isVotedUp
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          context.read<GalleryDetailBloc>().add(VoteComment(
                                gid: gid,
                                token: token,
                                commentId: comment.id,
                                isUpvote: false,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            comment.isVotedDown
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            size: 14,
                            color: comment.isVotedDown
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentContent(BuildContext context, String html) {
    final plainText = _stripHtml(html);
    final style = Theme.of(context).textTheme.bodyMedium!;
    final linkStyle = style.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    final urlRegex = RegExp(
      r'https?://(?:e-hentai|exhentai)\.org/g/\d+/[a-f0-9]+/?',
    );

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in urlRegex.allMatches(plainText)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: plainText.substring(lastEnd, match.start)));
      }
      final url = match.group(0)!;
      final parsed = EhUrlParser.parseGalleryUrl(url);
      spans.add(TextSpan(
        text: url,
        style: linkStyle,
        recognizer: parsed != null
            ? (TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/gallery', arguments: {
                  'gid': parsed.$1,
                  'token': parsed.$2,
                });
              })
            : null,
      ));
      lastEnd = match.end;
    }

    if (lastEnd < plainText.length) {
      spans.add(TextSpan(text: plainText.substring(lastEnd)));
    }

    if (spans.isEmpty) {
      return Text(plainText, style: style);
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }

  String _stripHtml(String html) {
    final withLinks = html.replaceAllMapped(
      RegExp(
          r'<a\s[^>]*href="(https?://(?:e-hentai|exhentai)\.org/g/[^"]+)"[^>]*>(.*?)</a>',
          caseSensitive: false),
      (m) {
        final href = m.group(1)!;
        final text = m.group(2)!.replaceAll(RegExp(r'<[^>]+>'), '').trim();
        if (text.contains('e-hentai.org/g/') ||
            text.contains('exhentai.org/g/')) {
          return text;
        }
        return '$text $href';
      },
    );
    return withLinks
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
