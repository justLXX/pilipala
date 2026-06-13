import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/init.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class SetCookie {
  static onSet() async {
    // webview_cookie_manager 仅支持 Android/iOS，桌面平台跳过
    if (!defaultTargetPlatform.toString().contains('android') &&
        !defaultTargetPlatform.toString().contains('iOS')) {
      return;
    }
    try {
      var cookies =
          await WebviewCookieManager().getCookies(HttpString.baseUrl);
      await Request.cookieManager.cookieJar
          .saveFromResponse(Uri.parse(HttpString.baseUrl), cookies);
      var cookieString =
          cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
      Request.dio.options.headers['cookie'] = cookieString;

      cookies =
          await WebviewCookieManager().getCookies(HttpString.apiBaseUrl);
      await Request.cookieManager.cookieJar
          .saveFromResponse(Uri.parse(HttpString.apiBaseUrl), cookies);

      cookies = await WebviewCookieManager().getCookies(HttpString.tUrl);
      await Request.cookieManager.cookieJar
          .saveFromResponse(Uri.parse(HttpString.tUrl), cookies);
    } on MissingPluginException {
      // 插件未实现（如 macOS），静默忽略
      debugPrint('webview_cookie_manager 不支持当前平台，跳过 cookie 同步');
    }
  }
}
