import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/plugin/pl_gallery/index.dart';
import 'package:pilipala/models/video/reply/content.dart';
import 'package:pilipala/utils/utils.dart';

class CommentContent extends StatelessWidget {
  const CommentContent({
    required this.content,
    this.maxLines,
    super.key,
  });

  final ReplyContent content;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return buildContentWidget(context);
  }

  Widget buildContentWidget(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<InlineSpan> spanChildren = <InlineSpan>[];

    // 处理投票
    String message = content.message ?? '';
    if (content.vote != null && content.vote!.isNotEmpty) {
      message = message.replaceAll(RegExp(r'\{vote:.*?\}'), ' ');
      spanChildren.add(
        TextSpan(
          text: '投票: ${content.vote!['title']}',
          style: TextStyle(color: colorScheme.primary),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Get.toNamed(
                  '/webview',
                  parameters: {
                    'url': content.vote!['url'] ?? '',
                    'type': 'vote',
                    'pageTitle': content.vote!['title'] ?? '',
                  },
                ),
        ),
      );
    }
    message = message.replaceAll(RegExp(r'\{vote:.*?\}'), ' ');
    // HTML实体解码
    message = message
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    // 构建特殊 token 正则
    final List<String> specialTokens = [
      ...(content.emote?.keys.map((dynamic e) => RegExp.escape(e.toString())) ?? <String>[]),
      ...(content.atNameToMid?.keys.map((dynamic e) => '@$e') ?? <String>[]),
    ];

    // jumpUrl keys 需要转义正则特殊字符
    List<dynamic> jumpUrlKeysList = content.jumpUrl?.keys.map((e) {
          return e.replaceAllMapped(
              RegExp(r'[?+*]'), (match) => '\\${match.group(0)}');
        }).toList() ??
        [];

    String patternStr = specialTokens.join('|');
    if (patternStr.isNotEmpty) {
      patternStr += '|';
    }
    if (jumpUrlKeysList.isNotEmpty) {
      patternStr += jumpUrlKeysList.join('|');
    }

    List<String> matchedStrs = [];

    void addPlainTextSpan(String str) {
      spanChildren.add(TextSpan(text: str));
    }

    if (patternStr.isNotEmpty) {
      final RegExp pattern = RegExp(patternStr);
      message.splitMapJoin(
        pattern,
        onMatch: (Match match) {
          final String matchStr = match[0]!;
          // 1. 表情渲染
          if (content.emote != null && content.emote!.containsKey(matchStr)) {
            final int size =
                content.emote![matchStr]['meta']['size'] as int? ?? 1;
            spanChildren.add(
              WidgetSpan(
                child: NetworkImgLayer(
                  src: content.emote![matchStr]['url'],
                  type: 'emote',
                  width: size * 20.0,
                  height: size * 20.0,
                ),
              ),
            );
          }
          // 2. @用户
          else if (matchStr.startsWith('@') &&
              content.atNameToMid != null &&
              content.atNameToMid!
                  .containsKey(matchStr.substring(1))) {
            final String userName = matchStr.substring(1);
            final dynamic userId = content.atNameToMid![userName];
            spanChildren.add(
              TextSpan(
                text: matchStr,
                style: TextStyle(color: colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final String heroTag = Utils.makeHeroTag(userId);
                    Get.toNamed(
                      '/member?mid=$userId',
                      arguments: {'face': '', 'heroTag': heroTag},
                    );
                  },
              ),
            );
          }
          // 3. jumpUrl 链接
          else if (content.jumpUrl != null &&
              content.jumpUrl!.containsKey(matchStr) &&
              !matchedStrs.contains(matchStr)) {
            final String appUrlSchema =
                content.jumpUrl![matchStr]['app_url_schema'] ?? '';
            spanChildren.addAll([
              if (content.jumpUrl![matchStr]?['prefix_icon'] != null)
                WidgetSpan(
                  child: Image.network(
                    content.jumpUrl![matchStr]['prefix_icon'],
                    height: 19,
                    color: colorScheme.primary,
                  ),
                ),
              TextSpan(
                text: content.jumpUrl![matchStr]['title'] ?? matchStr,
                style: TextStyle(color: colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final String title =
                        content.jumpUrl![matchStr]['title'] ?? '';
                    if (appUrlSchema.startsWith('bilibili://search')) {
                      Get.toNamed('/searchResult',
                          parameters: {'keyword': title});
                    } else if (matchStr.startsWith('https://b23.tv')) {
                      Get.toNamed(
                        '/webview',
                        parameters: {
                          'url': matchStr,
                          'type': 'url',
                          'pageTitle': title,
                        },
                      );
                    } else {
                      Get.toNamed(
                        '/webview',
                        parameters: {
                          'url': matchStr,
                          'type': 'url',
                          'pageTitle': title,
                        },
                      );
                    }
                  },
              ),
            ]);
            matchedStrs.add(matchStr);
          } else {
            addPlainTextSpan(matchStr);
          }
          return '';
        },
        onNonMatch: (String nonMatchStr) {
          addPlainTextSpan(nonMatchStr);
          return nonMatchStr;
        },
      );
    } else {
      addPlainTextSpan(message);
    }

    // 处理未在文本中出现的 jumpUrl
    if (content.jumpUrl != null && content.jumpUrl!.keys.isNotEmpty) {
      final List<String> unmatchedItems = content.jumpUrl!.keys
          .where((item) => !message.contains(item))
          .toList()
          .cast<String>();
      for (final String patternStr in unmatchedItems) {
        spanChildren.addAll([
          if (content.jumpUrl![patternStr]?['prefix_icon'] != null)
            WidgetSpan(
              child: Image.network(
                content.jumpUrl![patternStr]['prefix_icon'],
                height: 19,
                color: colorScheme.primary,
              ),
            ),
          TextSpan(
            text: content.jumpUrl![patternStr]['title'] ?? patternStr,
            style: TextStyle(color: colorScheme.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  '/webview',
                  parameters: {
                    'url': patternStr,
                    'type': 'url',
                    'pageTitle':
                        content.jumpUrl![patternStr]['title'] ?? '',
                  },
                );
              },
          ),
        ]);
      }
    }

    // 4. 图片渲染
    if (content.pictures != null && content.pictures!.isNotEmpty) {
      spanChildren.add(const TextSpan(text: '\n'));
      final int len = content.pictures!.length;
      final List<String> picList = content.pictures!
          .map((e) => (e as Map)['img_src'] as String)
          .toList();
      if (len == 1) {
        final Map pictureItem = content.pictures!.first as Map;
        spanChildren.add(
          WidgetSpan(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints box) {
                double maxHeight = box.maxWidth * 0.6;
                double height = 100;
                try {
                  height = ((box.maxWidth /
                          2 *
                          pictureItem['img_height'] /
                          pictureItem['img_width']))
                      .truncateToDouble();
                } catch (_) {}
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HeroDialogRoute<void>(
                        builder: (BuildContext context) =>
                            InteractiveviewerGallery(
                          sources: picList,
                          initIndex: 0,
                          onPageChanged: (int pageIndex) {},
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 4),
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    width: box.maxWidth / 2,
                    height: height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImgLayer(
                        src: pictureItem['img_src'],
                        width: box.maxWidth / 2,
                        height: height,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else if (len > 1) {
        List<Widget> list = [];
        for (var i = 0; i < len; i++) {
          final int index = i;
          list.add(
            LayoutBuilder(
              builder: (context, BoxConstraints box) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      HeroDialogRoute<void>(
                        builder: (BuildContext context) =>
                            InteractiveviewerGallery(
                          sources: picList,
                          initIndex: index,
                          onPageChanged: (int pageIndex) {},
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: NetworkImgLayer(
                      src: content.pictures![index]['img_src'],
                      width: box.maxWidth,
                      height: box.maxWidth,
                      origAspectRatio:
                          content.pictures![index]['img_width'] /
                              content.pictures![index]['img_height'],
                    ),
                  ),
                );
              },
            ),
          );
        }
        spanChildren.add(
          WidgetSpan(
            child: LayoutBuilder(
              builder: (context, BoxConstraints box) {
                double maxWidth = box.maxWidth;
                double crossCount = len < 3 ? 2.0 : 3.0;
                double height = maxWidth /
                        crossCount *
                        (len % crossCount.toInt() == 0
                            ? len ~/ crossCount.toInt()
                            : len ~/ crossCount.toInt() + 1) +
                    6;
                return Container(
                  padding: const EdgeInsets.only(top: 6),
                  height: height,
                  child: GridView.count(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossCount.toInt(),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    childAspectRatio: 1,
                    children: list,
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    // 笔记链接
    if (content.richText != null && content.richText!.isNotEmpty) {
      spanChildren.add(
        TextSpan(
          text: ' 笔记',
          style: TextStyle(color: colorScheme.primary),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Get.toNamed(
                  '/webview',
                  parameters: {
                    'url': content.richText!['note']?['click_url'] ?? '',
                    'type': 'note',
                    'pageTitle': '笔记预览',
                  },
                ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spanChildren),
      style: const TextStyle(height: 1.75),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
