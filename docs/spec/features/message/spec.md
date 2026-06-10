# 消息功能规格书

## 1. 功能描述

消息页面展示用户的各类通知，包括回复我的、@我的、收到的赞、系统通知等。支持私信功能。

## 2. 用户流程

```
用户进入消息页面
    │
    ├── 查看消息分类
    │   ├── 回复我的
    │   ├── @我的
    │   ├── 收到的赞
    │   └── 系统通知
    │
    ├── 查看私信
    │   ├── 私信会话列表
    │   ├── 进入会话详情
    │   └── 发送私信
    │
    └── 操作
        ├── 标记已读
        └── 删除消息
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 私信列表 | `/whisper` | `lib/pages/whisper/view.dart` | 私信会话列表 |
| 私信详情 | `/whisperDetail` | `lib/pages/whisper_detail/view.dart` | 私信详情页面 |
| 回复我的 | `/messageReply` | `lib/pages/message/reply/view.dart` | 回复通知 |
| @我的 | `/messageAt` | `lib/pages/message/at/view.dart` | @通知 |
| 收到的赞 | `/messageLike` | `lib/pages/message/like/view.dart` | 点赞通知 |
| 系统通知 | `/messageSystem` | `lib/pages/message/system/view.dart` | 系统通知 |

## 4. Controller 职责

### 4.1 WhisperController

文件：`lib/pages/whisper/controller.dart`

职责：
- 管理私信会话列表
- 发送私信

```dart
class WhisperController extends GetxController {
  RxList<SessionList> sessionList = <SessionList>[].obs;
  RxBool isLoading = false.obs;
  
  Future<void> querySessionList() async;
  Future<void> sendMessage(int talkerId, String content) async;
}
```

### 4.2 MessageReplyController

文件：`lib/pages/message/reply/controller.dart`

职责：
- 管理回复通知列表

```dart
class MessageReplyController extends GetxController {
  RxList<MessageReplyItem> replyList = <MessageReplyItem>[].obs;
  
  Future<void> queryReplyList() async;
}
```

## 5. 数据模型

### 5.1 私信会话

文件：`lib/models/msg/session.dart`

```dart
class SessionDataModel {
  List<SessionList>? sessionList;
  int? hasMore;
}

class SessionList {
  int? talkerId;
  int? sessionType;
  String? groupName;
  String? groupCover;
  bool? isFollow;
  String? lastMsg;
  int? unreadCount;
}
```

### 5.2 回复通知

文件：`lib/models/msg/reply.dart`

```dart
class MessageReplyModel {
  Cursor? cursor;
  List<MessageReplyItem>? items;
}

class MessageReplyItem {
  int? id;
  User? user;
  String? item;
  String? reply;
  int? isRead;
}
```

## 6. API 依赖

### 6.1 获取会话列表

```
GET https://api.vc.bilibili.com/session_svr/v1/session_svr/get_sessions
```

参数：
- `session_type`：会话类型
- `group_fold`：是否折叠群聊
- `unfollow_fold`：是否折叠未关注

### 6.2 发送私信

```
POST https://api.vc.bilibili.com/web_im/v1/web_im/send_msg
```

参数：
- `msg[receiver_id]`：接收者 ID
- `msg[receiver_type]`：接收者类型
- `msg[msg_type]`：消息类型
- `msg[content]`：消息内容
- `csrf`：CSRF Token

### 6.3 获取回复通知

```
GET /x/msgfeed/reply
```

参数：
- `id`：上次最后一条 ID

## 7. 状态管理

### 7.1 消息状态

```
[初始状态]
    │
    ├── querySessionList()
    │   ├── 请求 API
    │   └── 成功 → sessionList = data
    │
    ├── queryReplyList()
    │   ├── 请求 API
    │   └── 成功 → replyList = data
    │
    └── sendMessage()
        ├── 请求 API
        └── 成功 → 刷新会话列表
```

## 8. 注意事项

- 消息功能需要登录状态
- 支持消息未读数显示
- 私信支持发送文字和表情
- 系统通知支持标记已读
- 消息列表支持分页加载
