import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseService {
  final baseUrl = 'https://localhost:7090/api/v1';

  final storage = const FlutterSecureStorage();

}