import 'package:flutter/material.dart';

class MessageAtPage extends StatefulWidget {
  const MessageAtPage({super.key});

  @override
  State<MessageAtPage> createState() => _MessageAtPageState();
}

class _MessageAtPageState extends State<MessageAtPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: const Text('@我的'),
      ),
      body: Center(
        child: Text(
          '功能开发中',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}
