import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/badge.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/utils/utils.dart';
import 'comment_content.dart';

class CommentItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String heroTag = Utils.makeHeroTag(replyItem.mid ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 8, 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colorScheme.onInverseSurface.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 头像行 + 右侧列
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.toNamed('/member?mid=${replyItem.mid}', arguments: {
                'face': replyItem.member?.avatar ?? '',
                'heroTag': heroTag,
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 头像
                NetworkImgLayer(
                  src: replyItem.member?.avatar,
                  width: 34,
                  height: 34,
                  type: 'avatar',
                ),
                const SizedBox(width: 12),
                // 右侧列
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // a. 用户名行
                      _buildUserNameRow(context, colorScheme),
                      const SizedBox(height: 2),
                      // b. 时间行
                      _buildTimeRow(context, colorScheme, textTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // c. 评论内容
          Container(
            margin: const EdgeInsets.only(
                top: 10, left: 45, right: 6, bottom: 4),
            child: Text.rich(
              style: const TextStyle(height: 1.75),
              maxLines:
                  replyItem.content?.isText == true && replyLevel == '1'
                      ? 3
                      : 999,
              overflow: TextOverflow.ellipsis,
              TextSpan(
                children: [
                  // e. 置顶/热评标签
                  if (replyItem.isTop == true)
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.top,
                      child: PBadge(
                        text: 'TOP',
                        size: 'small',
                        stack: 'normal',
                        type: 'line',
                        fs: 9,
                      ),
                    ),
                  // 评论富文本内容
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: CommentContent(
                      content: replyItem.content!,
                      maxLines:
                          replyItem.content?.isText == true &&
                                  replyLevel == '1'
                              ? 3
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // d. 操作行
          _buildActionRow(context, colorScheme, textTheme),
          // 热评标签（在操作行之后）
          if (replyItem.cardLabel != null &&
              replyItem.cardLabel!.isNotEmpty &&
              replyItem.cardLabel!.any((e) => e.toString().contains('热评')))
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
          // 3. 二级评论预览
          if (replyItem.replies != null &&
              replyItem.replies!.isNotEmpty &&
              showReplyRow)
            _buildSubRepliesPreview(context, colorScheme),
        ],
      ),
    );
  }

  /// 用户名行：用户名 + 等级徽章 + UP主标签 + VIP标记
  Widget _buildUserNameRow(BuildContext context, ColorScheme colorScheme) {
    final bool isVip =
        replyItem.member?.vip != null && replyItem.member!.vip!['vipStatus'] == 1;
    return Row(
      children: [
        Text(
          replyItem.member?.uname ?? '',
          style: TextStyle(
            color: isVip ? const Color(0xFFFB7299) : colorScheme.outline,
            fontSize: 13,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: Image.asset(
            'assets/images/lv/lv${replyItem.member?.level ?? 0}.png',
            height: 11,
          ),
        ),
        if (replyItem.isUp == true)
          const PBadge(
            text: 'UP',
            size: 'small',
            stack: 'normal',
            fs: 9,
          ),
      ],
    );
  }

  /// 时间行：发布时间 + IP属地
  Widget _buildTimeRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: Utils.dateFormat(replyItem.ctime),
            style: TextStyle(
              fontSize: textTheme.labelSmall?.fontSize,
              color: colorScheme.outline,
            ),
          ),
          if (replyItem.replyControl != null &&
              replyItem.replyControl!.location != null &&
              replyItem.replyControl!.location!.isNotEmpty)
            TextSpan(
              text: ' • ${replyItem.replyControl!.location}',
              style: TextStyle(
                fontSize: textTheme.labelSmall?.fontSize,
                color: colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  /// 操作行：点赞按钮 + 回复数
  Widget _buildActionRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        const SizedBox(width: 32),
        // 点赞按钮
        SizedBox(
          height: 32,
          child: TextButton(
            onPressed: () {
              final int newAction = replyItem.action == 0 ? 1 : 0;
              onLike?.call(replyItem.rpid ?? 0, newAction);
            },
            child: Row(
              children: [
                Icon(
                  replyItem.action == 1
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  size: 14,
                  color: replyItem.action == 1
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  replyItem.like != null && replyItem.like! > 0
                      ? '${replyItem.like}'
                      : '点赞',
                  style: TextStyle(
                    fontSize: textTheme.labelSmall?.fontSize,
                    color: replyItem.action == 1
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 回复按钮
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => onReply?.call(replyItem),
          child: Icon(
            Icons.comment_outlined,
            size: 14,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => onReply?.call(replyItem),
          child: Text(
            '回复',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline,
            ),
          ),
        ),
        // 回复数
        if (replyItem.count != null &&
            replyItem.count! > 0 &&
            showReplyRow) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onReplyTap?.call(replyItem),
            child: Text(
              '共${replyItem.count}条回复',
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

  /// 二级评论预览：显示前3条子评论的简略文字
  Widget _buildSubRepliesPreview(
      BuildContext context, ColorScheme colorScheme) {
    final List replies = replyItem.replies!;
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
              onTap: () => onReplyTap?.call(replyItem),
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

  /// 单条二级评论简略文字（"用户名：内容" 格式，单行省略）
  Widget _buildSubReplyItem(BuildContext context, ReplyItemModel subReply) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String userName = subReply.member?.uname ?? '';
    final String message = subReply.content?.message ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
    );
  }
}
