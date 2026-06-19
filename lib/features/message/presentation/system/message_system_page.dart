import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/models/msg/system.dart';
import 'message_system_controller.dart';

class MessageSystemPage extends StatefulWidget {
  const MessageSystemPage({super.key});

  @override
  State<MessageSystemPage> createState() => _MessageSystemPageState();
}

class _MessageSystemPageState extends State<MessageSystemPage> {
  final MessageSystemController _messageSystemCtr =
      Get.find<MessageSystemController>();
  late Future _futureBuilderFuture;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _messageSystemCtr.queryAndProcessMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: const Text('系统通知'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _messageSystemCtr.queryAndProcessMessages();
        },
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == null) {
                return const SizedBox();
              }
              if (snapshot.data['status']) {
                final systemItems = _messageSystemCtr.systemItems;
                return Obx(
                  () => ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                    itemBuilder: (context, index) => SystemItem(
                      item: systemItems[index],
                      index: index,
                      messageSystemCtr: _messageSystemCtr,
                    ),
                    itemCount: systemItems.length,
                  ),
                );
              } else {
                // 请求错误
                return CustomScrollView(
                  slivers: [
                    HttpError(
                      errMsg: snapshot.data['msg'],
                      fn: () {
                        setState(() {
                          _futureBuilderFuture =
                              _messageSystemCtr.queryMessageSystem();
                        });
                      },
                    )
                  ],
                );
              }
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class SystemItem extends StatelessWidget {
  final MessageSystemModel item;
  final int index;
  final MessageSystemController messageSystemCtr;

  const SystemItem(
      {super.key,
      required this.item,
      required this.index,
      required this.messageSystemCtr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.timeAt!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 8),
                Text(
                  item.content is String ? item.content : item.content!['web'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
