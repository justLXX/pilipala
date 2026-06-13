import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/dynamics.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/emote.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/pages/emote/index.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class VideoReplyNewDialog extends StatefulWidget {
  final int? oid;
  final int? root;
  final int? parent;
  final ReplyType? replyType;
  final ReplyItemModel? replyItem;

  const VideoReplyNewDialog({
    super.key,
    this.oid,
    this.root,
    this.parent,
    this.replyType,
    this.replyItem,
  });

  @override
  State<VideoReplyNewDialog> createState() => _VideoReplyNewDialogState();
}

class _VideoReplyNewDialogState extends State<VideoReplyNewDialog>
    with WidgetsBindingObserver {
  final TextEditingController _replyContentController = TextEditingController();
  final FocusNode replyContentFocusNode = FocusNode();
  final GlobalKey _formKey = GlobalKey<FormState>();
  late double emoteHeight = 0.0;
  double keyboardHeight = 0.0;
  final _debouncer = Debouncer(milliseconds: 200);
  String toolbarType = 'input';
  RxBool isForward = false.obs;
  RxBool showForward = false.obs;
  RxString message = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoFocus();
    _focuslistener();
    final String routePath = Get.currentRoute;
    if (routePath.startsWith('/video')) {
      showForward.value = true;
    }
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      FocusScope.of(context).requestFocus(replyContentFocusNode);
    }
  }

  _focuslistener() {
    replyContentFocusNode.addListener(() {
      if (replyContentFocusNode.hasFocus) {
        setState(() {
          toolbarType = 'input';
        });
      }
    });
  }

  Future submitReplyAdd() async {
    feedBack();
    var result = await VideoHttp.replyAdd(
      type: widget.replyType ?? ReplyType.video,
      oid: widget.oid!,
      root: widget.root!,
      parent: widget.parent!,
      message: widget.replyItem != null && widget.replyItem!.root != 0
          ? ' 回复 @${widget.replyItem!.member!.uname!} : ${message.value}'
          : message.value,
    );
    if (result['status']) {
      SmartDialog.showToast(result['data']['success_toast']);
      safeBack(result: {
        'data': ReplyItemModel.fromJson(result['data']['reply'], ''),
      });
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyContentController,
                    focusNode: replyContentFocusNode,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: '写评论...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      message.value = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: message.value.isNotEmpty ? submitReplyAdd : null,
                  icon: Icon(
                    Icons.send,
                    color: message.value.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replyContentController.dispose();
    replyContentFocusNode.dispose();
    super.dispose();
  }
}
