import 'package:arpicoiam/iam.dart';

class Api {
  static Future<void> ping() async {
    final dio = ApiManager.client.dio;
    await dio.get('');
  }
}