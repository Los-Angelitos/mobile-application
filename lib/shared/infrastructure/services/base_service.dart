import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweetmanager/shared/infrastructure/misc/token_helper.dart';

abstract class BaseService {
  final baseUrl = 'https://sweet-manager-api.runasp.net/api/v1';

  final storage = const FlutterSecureStorage();

  final tokenHelper = TokenHelper();
}