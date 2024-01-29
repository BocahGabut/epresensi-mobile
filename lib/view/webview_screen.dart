import 'package:e_absensi/service/api_service.dart';
import 'package:e_absensi/utils/global.const.dart';
import 'package:e_absensi/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:url_launcher/url_launcher.dart';

class WebViewApp extends StatefulWidget {
  final String accessToken;

  const WebViewApp({super.key, required this.accessToken});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  InAppWebViewController? _webViewController;
  final String _url = GlobalConst.urlApp;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController?.canGoBack() ?? false) {
          _webViewController?.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
                decoration: const BoxDecoration(
              color: Colors
                  .transparent,
            )),
            Expanded(
              child: FutureBuilder<bool>(
                future: checkServerAccess(
                    widget.accessToken), // Metode untuk memeriksa ke server
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.data!) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const WebViewApp(
                          accessToken: "",
                        ),
                      ),
                    );
                    return const Center(
                      child: Text('Akses ditolak. Silakan coba lagi nanti.'),
                    );
                  } else {
                    // Jika akses ke server diperbolehkan, muat WebView
                    return InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(_url),
                        headers: {
                          'Authorization': 'Bearer ${widget.accessToken}',
                        },
                      ),
                      initialSettings: InAppWebViewSettings(
                          underPageBackgroundColor: Colors.white,
                          preferredContentMode:
                              UserPreferredContentMode.DESKTOP,
                          forceDark: ForceDark.OFF,
                          geolocationEnabled: true,
                          allowFileAccessFromFileURLs: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowUniversalAccessFromFileURLs: true,
                          allowsInlineMediaPlayback: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          useOnDownloadStart: true,
                          builtInZoomControls: false),
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        final uri = navigationAction.request.url;
                        final url = Uri.parse(uri.toString());

                        if (url
                            .toString()
                            .startsWith('https://docs.google.com')) {
                          openExternalBrowser(url.toString());
                          return NavigationActionPolicy.CANCEL;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onWebViewCreated: (controller) async {
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('zeus-token', '${widget.accessToken}')");

                        final Position position =
                            await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high);
                        await controller.evaluateJavascript(
                            source:
                                "window.document.body.classList.add('mobile-apps')");
                        await controller.evaluateJavascript(
                            source:
                                "window.document.body.classList.add('theme-light')");
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('location-latitude', '${position.latitude}')");
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('location-longitude', '${position.longitude}')");

                        controller.addJavaScriptHandler(
                          handlerName: 'logoutSuccess',
                          callback: (_) {
                            _logout(context);
                            print('Logout Success');
                          },
                        );
                        _webViewController = controller;
                      },
                      onLoadStart: (controller, url) async {
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('zeus-token', '${widget.accessToken}')");
                        await controller.evaluateJavascript(
                            source:
                                "window.document.body.classList.add('mobile-apps')");

                        final Position position =
                            await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high);
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('location-latitude', '${position.latitude}')");
                        await controller.evaluateJavascript(
                            source:
                                "window.localStorage.setItem('location-longitude', '${position.longitude}')");
                      },
                      onReceivedServerTrustAuthRequest:
                          (controller, challenge) async {
                        return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED,
                        );
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkServerAccess(token) async {
    try {
      final bool loginSuccess = await ApiService.checkAuth(token);
      if (!loginSuccess) {
        const FlutterSecureStorage secureStorage = FlutterSecureStorage();
        await secureStorage.delete(key: 'access_token');
        await secureStorage.delete(key: 'isLogin');
      }

      return loginSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<void> _logout(context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'access_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Future<void> openExternalBrowser(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> downloadFile(String url, [String? filename]) async {
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    if (hasStoragePermission) {
      try {
        final fileDownload = await FlutterDownloader.enqueue(
          url: url,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
          // optional: header send with url (auth token etc)
          savedDir: (await getTemporaryDirectory()).path,
          saveInPublicStorage: true,
          fileName: filename,
          showNotification: true,
        );
        print(fileDownload);
      } catch (e) {
        print(e);
      }
    }
  }
}
