import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddit_bunshin/core/util/contract/app_contracts.dart';

class StorageHelper {
  late Box<dynamic> _box;

  static StorageHelper? _instance;

  static StorageHelper get instance {
    _instance ??= StorageHelper._private();

    return _instance!;
  }

  StorageHelper._private() {
    _box = Hive.box(AppContracts.appBox);
  }

  Future<void> writeValue({required String key, required dynamic value}) async {
    _box.put(key, value);
  }

  dynamic readValue(String key) {
    return _box.get(key);
  }

  Future<void> clearData() {
    return _box.clear();
  }
}
