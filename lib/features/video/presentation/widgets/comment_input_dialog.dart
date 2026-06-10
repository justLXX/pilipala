import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/models/video/reply/emote.dart';
import 'package:pilipala/pages/emote/view.dart';
import 'package:pilipala/utils/feed_back.dart';

class CommentInputDialog extends StatefulWidget {
  const CommentInputDialog({
    required this.oid,
    this.root = 0,
    this.parent = 0,
    this.replyItem,
    super.key,
  });
  final int oid;
  final int root;
  final int parent;
  final ReplyItemModel? replyItem;

  @override
  State<CommentInputDialog> createState() => _CommentInputDialogState();
}

enum _PanelMode { keyboard, emoji }

class _CommentInputDialogState extends State<CommentInputDialog>
    with WidgetsBindingObserver {
  final TextEditingController _replyContentController = TextEditingController();
  final FocusNode replyContentFocusNode = FocusNode();
  final _debouncer = Debouncer(milliseconds: 200);
  RxString message = ''.obs;

  _PanelMode _panelMode = _PanelMode.keyboard;
  double _cachedKeyboardHeight = 260;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoFocus();
    _focusListener();
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      FocusScope.of(context).requestFocus(replyContentFocusNode);
    }
  }

  _focusListener() {
    replyContentFocusNode.addListener(() {
      if (replyContentFocusNode.hasFocus && _panelMode != _PanelMode.keyboard) {
        setState(() {
          _panelMode = _PanelMode.keyboard;
        });
      }
    });
  }

  Future submitReplyAdd() async {
    feedBack();
    var result = await VideoHttp.replyAdd(
      type: ReplyType.video,
      oid: widget.oid,
      root: widget.root == 0 ? null : widget.root,
      parent: widget.parent == 0 ? null : widget.parent,
      message: widget.replyItem != null && widget.replyItem!.root != 0
          ? ' 回复 @${widget.replyItem!.member!.uname!} : ${message.value}'
          : message.value,
    );
    if (result['status']) {
      SmartDialog.showToast(result['data']['success_toast']);
      Get.back(result: {
        'data': ReplyItemModel.fromJson(result['data']['reply'], ''),
      });
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  void onChooseEmote(PackageItem package, Emote emote) {
    final int cursorPosition = _replyContentController.selection.baseOffset;
    final String currentText = _replyContentController.text;
    final String newText = currentText.substring(0, cursorPosition) +
        emote.text! +
        currentText.substring(cursorPosition);
    message.value = newText;
    _replyContentController.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: cursorPosition + emote.text!.length),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _debouncer.run(() {
          if (!mounted) return;
          final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          setState(() {
            _keyboardVisible = currentKeyboardHeight > 0;
            if (currentKeyboardHeight > 0) {
              _cachedKeyboardHeight = currentKeyboardHeight;
            }
          });
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replyContentController.dispose();
    replyContentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = widget.replyItem != null
        ? '回复 @${widget.replyItem!.member?.uname ?? ''}'
        : '写评论...';

    final bool isKeyboardMode = _panelMode == _PanelMode.keyboard;
    final bool isEmojiMode = _panelMode == _PanelMode.emoji;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input field area
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
              minHeight: 120,
            ),
            child: Container(
              padding:
                  const EdgeInsets.only(top: 12, right: 15, left: 15, bottom: 10),
              child: SingleChildScrollView(
                child: TextField(
                  controller: _replyContentController,
                  minLines: 3,
                  maxLines: 5,
                  autofocus: false,
                  focusNode: replyContentFocusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(fontSize: 14),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (text) {
                    message.value = text;
                  },
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          // Toolbar
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 12, right: 12),
            margin: EdgeInsets.only(
              bottom: isKeyboardMode && !_keyboardVisible
                  ? MediaQuery.of(context).padding.bottom
                  : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Keyboard button
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      if (isEmojiMode) {
                        setState(() {
                          _panelMode = _PanelMode.keyboard;
                        });
                      }
                      FocusScope.of(context).requestFocus(replyContentFocusNode);
                    },
                    icon: const Icon(Icons.keyboard, size: 22),
                    color: isKeyboardMode
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.outline,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => isKeyboardMode
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Emote button
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      if (isKeyboardMode) {
                        setState(() {
                          _panelMode = _PanelMode.emoji;
                        });
                      }
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.emoji_emotions, size: 22),
                    color: isEmojiMode
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.outline,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => isEmojiMode
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null),
                    ),
                  ),
                ),
                const Spacer(),
                // Send button
                SizedBox(
                  height: 36,
                  child: Obx(
                    () => FilledButton(
                      onPressed:
                          message.isNotEmpty ? submitReplyAdd : null,
                      child: const Text('发送'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Emote / Keyboard area
          AnimatedSize(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              width: double.infinity,
              height: isEmojiMode ? _cachedKeyboardHeight : 0,
              child: Offstage(
                offstage: isKeyboardMode,
                child: EmotePanel(
                  onChoose: (package, emote) => onChooseEmote(package, emote),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef DebounceCallback = void Function();

class Debouncer {
  DebounceCallback? callback;
  final int? milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(DebounceCallback callback) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), () {
      callback();
    });
  }
}
