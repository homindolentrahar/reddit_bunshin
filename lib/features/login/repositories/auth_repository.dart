import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_bunshin/core/di/app_injection.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';
import 'package:reddit_bunshin/core/util/constant/app_constants.dart';
import 'package:reddit_bunshin/core/util/extension/firestore_ext.dart';
import 'package:reddit_bunshin/models/user_model.dart';

class AuthRepository {
  String tag = "AuthRepository::->";

  static final provider = Provider<AuthRepository>(
    (ref) => AuthRepository(
      firebaseAuth: ref.read(AppInjection.firebaseAuth),
      googleSignIn: ref.read(AppInjection.googleSignIn),
      firestore: ref.read(AppInjection.firestore),
    ),
  );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  Stream<Option<User>> get authStateChange =>
      _firebaseAuth.authStateChanges().map((user) => optionOf(user));

  Stream<UserModel> watchUserData(String uid) => _firestore.userRef
      .doc(uid)
      .snapshots()
      .map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));

  Future<Either<AppError, UserModel>> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(AppError("User cancel the login process"));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (isFromLogin) {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } else {
        userCredential =
            await _firebaseAuth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        userModel = UserModel(
          uid: userCredential.user?.uid ?? "-",
          name: userCredential.user?.displayName ?? "No Name",
          profile: userCredential.user?.photoURL ?? AppConstants.avatarDefault,
          banner: AppConstants.bannerDefault,
          isGuest: false,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );

        await _firestore.userRef
            .doc(userCredential.user?.uid)
            .set(userModel.toMap());
      } else {
        userModel = await watchUserData(userCredential.user?.uid ?? "").first;
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.message}");
      return left(AppError("${e.code}: ${e.message}"));
    }
  }

  Future<Either<AppError, UserModel>> signInAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final userModel = UserModel(
        name: 'Guest',
        profile: AppConstants.avatarDefault,
        banner: AppConstants.bannerDefault,
        uid: userCredential.user?.uid,
        isGuest: true,
        karma: 0,
        awards: [],
      );

      await _firestore.userRef
          .doc(userCredential.user?.uid)
          .set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.message}");
      return left(AppError("${e.code}: ${e.message}"));
    }
  }

  Future<Either<AppError, Unit>> signOut() async {
    try {
      Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.message}");
      return left(AppError("${e.code}: ${e.message}"));
    }
  }
}
