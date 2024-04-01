import 'dart:convert';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_music_app/utils/platform_utils.dart';

// 必须是顶层函数
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

abstract class BaseHttp extends DioForNative {
  BaseHttp() {
    /// 初始化 加入app通用处理
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

    /////Release环境时，inProduction为true
    // bool inProduction = bool.fromEnvironment("dart.vm.product");
    // if (!inProduction) {
    //   String proxy = "192.168.2.234:8888";
    //   (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (HttpClient client) {
    //     client.findProxy = (uri) {
    //       //proxy all request to localhost:8888
    //       return "PROXY $proxy";
    //     };
    //     client.badCertificateCallback =
    //         (X509Certificate cert, String host, int port) => true;
    //   };
    // }
    interceptors..add(HeaderInterceptor());
    init();
  }

  void init();
}

/// 添加常用Header
class HeaderInterceptor extends InterceptorsWrapper {
  @override
  onRequest( RequestOptions options,
      RequestInterceptorHandler handler,) async {
    options.connectTimeout = Duration(seconds: 45);
    options.receiveTimeout = Duration(seconds: 45);
    options.contentType = 'application/x-www-form-urlencoded; charset=UTF-8';

    //var appVersion = await PlatformUtils.getAppVersion();
    // var version = Map()
    //   ..addAll({
    //     'appVerison': appVersion,
    //   });
    //options.headers['version'] = version;
    options.headers['X-Requested-With'] = 'XMLHttpRequest';
    super.onRequest(options, handler);
    //options.headers['platform'] = Platform.operatingSystem;
    // return options;
  }
}

/// 子类需要重写
abstract class BaseResponseData {
  int code = 0;
  late String error;
  late dynamic data;

  bool get success;

  BaseResponseData({required this.code, required this.error, this.data});

  @override
  String toString() {
    return 'BaseRespData{code: $code, message: $error, data: $data}';
  }
}

/// 接口的code没有返回为true的异常
class NotSuccessException implements Exception {
  late final String error;

   NotSuccessException.fromRespData(BaseResponseData respData) {
    error = respData.error;
  }

  @override
  String toString() {
    return 'NotExpectedException{respData: $error}';
  }
}

/// 用于未登录等权限不够,需要跳转授权页面
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}