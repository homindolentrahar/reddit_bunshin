import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/di/app_injection.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';

class StorageRepository {
  String tag = "StorageRepository::->";

  // Providers
  static final provider = Provider(
    (ref) => StorageRepository(
      storage: ref.watch(AppInjection.storage),
    ),
  );

  final FirebaseStorage _storage;

  StorageRepository({required FirebaseStorage storage}) : _storage = storage;

  Future<Either<AppError, String>> storeFile({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(id);
      final uploadTask = await ref.putFile(file!);

      return right(await uploadTask.ref.getDownloadURL());
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }
}
