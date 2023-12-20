import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reddit_bunshin/core/util/contract/app_contracts.dart';

class SecureStorageHelper {
  late FlutterSecureStorage _secureStorage;

  static SecureStorageHelper? _instance;

  static SecureStorageHelper get instance {
    _instance ??= SecureStorageHelper._private();

    return _instance!;
  }

  SecureStorageHelper._private() {
    _secureStorage = const FlutterSecureStorage();
  }

  Future<void> saveUser(String id) async {
    await _secureStorage.write(key: AppContracts.user, value: id);
  }

  Future<String?> get getUser => _secureStorage.read(key: AppContracts.user);

  Future<void> clearData() {
    return _secureStorage.deleteAll();
  }
}
