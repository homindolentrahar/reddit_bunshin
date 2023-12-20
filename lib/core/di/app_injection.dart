import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AppInjection {
  static final firebaseAuth = Provider((ref) => FirebaseAuth.instance);
  static final firestore = Provider((ref) => FirebaseFirestore.instance);
  static final googleSignIn = Provider((ref) => GoogleSignIn());
  static final storage = Provider((ref) => FirebaseStorage.instance);
}
