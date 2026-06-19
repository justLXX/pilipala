import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/badge.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/utils/utils.dart';
import 'comment_content.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({
    required this.replyItem,
    this.replyLevel = '1',
    this.showReplyRow = true,
    this.onLike,
    this.onReplyTap,
    this.onReply,
    super.key,
  });

  final ReplyItemModel replyItem;
  final String replyLevel;
  final bool showReplyRow;
  final Function(int rpid, int action)? onLike;
  final Function(ReplyItemModel replyItem)? onReplyTap;
  final Function(ReplyItemModel replyItem)? onReply;

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _expanded = false;
  static const int _maxLines = 6;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String heroTag = Utils.makeHeroTag(widget.replyItem.mid ?? 0);

    // 只有一级文字评论才限制行数
    final bool isLimited = widget.replyItem.content?.isText == true &&
        widget.replyLevel == '1';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colorScheme.onInverseSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 头像行
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed('/member?mid=${widget.replyItem.mid}', arguments: {
                'face': widget.replyItem.member?.avatar ?? '',
                'heroTag': heroTag,
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NetworkImgLayer(
                  src: widget.replyItem.member?.avatar,
                  width: 34,
                  height: 34,
                  type: 'avatar',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserNameRow(context, colorScheme),
                      const SizedBox(height: 2),
                      _buildTimeRow(context, colorScheme, textTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 2. 评论内容
          Container(
            margin: const EdgeInsets.only(
                top: 10, left: 45, right: 6, bottom: 4),
            child: isLimited
                ? _buildLimitedContent(context, colorScheme)
                : CommentContent(content: widget.replyItem.content!),
          ),
          // 3. 操作行
          _buildActionRow(context, colorScheme, textTheme),
          // 热评标签
          if (widget.replyItem.cardLabel != null &&
              widget.replyItem.cardLabel!.isNotEmpty &&
              widget.replyItem.cardLabel!
                  .any((e) => e.toString().contains('热评')))
            Padding(
              padding: const EdgeInsets.only(left: 45, top: 2),
              child: Text(
                '热评',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: textTheme.labelMedium?.fontSize,
                ),
              ),
            ),
          // 4. 二级评论预览
          if (widget.replyItem.replies != null &&
              widget.replyItem.replies!.isNotEmpty &&
              widget.showReplyRow)
            _buildSubRepliesPreview(context, colorScheme),
        ],
      ),
    );
  }

  /// 带行数限制的评论内容：先测量是否溢出，再决定是否显示展开按钮
  Widget _buildLimitedContent(BuildContext context, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = widget.replyItem.content?.message ?? '';
        final span = TextSpan(
          text: text,
          style: const TextStyle(height: 1.75),
        );
        final tp = TextPainter(
          text: span,
          maxLines: _maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);
        final didOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommentContent(
              content: widget.replyItem.content!,
              maxLines: _expanded ? null : _maxLines,
            ),
            if (didOverflow)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? '收起' : '展开',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserNameRow(BuildContext context, ColorScheme colorScheme) {
    final bool isVip = widget.replyItem.member?.vip != null &&
        widget.replyItem.member!.vip!['vipStatus'] == 1;
    return Row(
      children: [
        Text(
          widget.replyItem.member?.uname ?? '',
          style: TextStyle(
            color: isVip ? const Color(0xFFFB7299) : colorScheme.outline,
            fontSize: 13,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Image.asset(
            'assets/images/lv/lv${widget.replyItem.member?.level ?? 0}.png',
            height: 11,
          ),
        ),
        if (widget.replyItem.isUp == true)
          const PBadge(
            text: 'UP',
            size: 'small',
            stack: 'normal',
            fs: 9,
          ),
      ],
    );
  }

  Widget _buildTimeRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: Utils.dateFormat(widget.replyItem.ctime),
            style: TextStyle(
              fontSize: textTheme.labelSmall?.fontSize,
              color: colorScheme.outline,
            ),
          ),
          if (widget.replyItem.replyControl != null &&
              widget.replyItem.replyControl!.location != null &&
              widget.replyItem.replyControl!.location!.isNotEmpty)
            TextSpan(
              text: ' • ${widget.replyItem.replyControl!.location}',
              style: TextStyle(
                fontSize: textTheme.labelSmall?.fontSize,
                color: colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        const SizedBox(width: 32),
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: () {
              final int newAction =
                  widget.replyItem.action == 0 ? 1 : 0;
              widget.onLike?.call(widget.replyItem.rpid ?? 0, newAction);
            },
            child: Row(
              children: [
                Icon(
                  widget.replyItem.action == 1
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  size: 14,
                  color: widget.replyItem.action == 1
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.replyItem.like != null && widget.replyItem.like! > 0
                      ? '${widget.replyItem.like}'
                      : '点赞',
                  style: TextStyle(
                    fontSize: textTheme.labelSmall?.fontSize,
                    color: widget.replyItem.action == 1
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => widget.onReply?.call(widget.replyItem),
          child: Icon(
            Icons.comment_outlined,
            size: 14,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => widget.onReply?.call(widget.replyItem),
          child: Text(
            '回复',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline,
            ),
          ),
        ),
        if (widget.replyItem.count != null &&
            widget.replyItem.count! > 0 &&
            widget.showReplyRow) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => widget.onReplyTap?.call(widget.replyItem),
            child: Text(
              '共${widget.replyItem.count}条回复',
              style: TextStyle(
                fontSize: textTheme.labelSmall?.fontSize,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
        const Spacer(),
      ],
    );
  }

  Widget _buildSubRepliesPreview(
      BuildContext context, ColorScheme colorScheme) {
    final List replies = widget.replyItem.replies!;
    final int showCount = replies.length > 3 ? 3 : replies.length;

    return Container(
      margin: const EdgeInsets.only(left: 42, right: 4, top: 5, bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < showCount; i++)
            _buildSubReplyItem(context, replies[i] as ReplyItemModel),
          if (replies.length > 3)
            GestureDetector(
              onTap: () => widget.onReplyTap?.call(widget.replyItem),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '查看更多回复',
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.labelMedium?.fontSize,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubReplyItem(BuildContext context, ReplyItemModel subReply) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String userName = subReply.member?.uname ?? '';
    final String message = subReply.content?.message ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () => widget.onReplyTap?.call(widget.replyItem),
        child: Text.rich(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          TextSpan(
            children: [
              TextSpan(
                text: '$userName：',
                style: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.titleSmall?.fontSize,
                  color: colorScheme.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Get.toNamed(
                        '/member?mid=${subReply.mid}',
                        arguments: {
                          'face': subReply.member?.avatar ?? '',
                          'heroTag': Utils.makeHeroTag(subReply.mid),
                        });
                  },
              ),
              TextSpan(
                text: message,
                style: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.bodySmall?.fontSize,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
