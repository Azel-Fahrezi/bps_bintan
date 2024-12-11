import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout =
          const Duration(seconds: 10) // Ubah timeout sesuai kebutuhan
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
