import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reddit_bunshin/core/util/contract/firestore_contracts.dart';

extension FirestoreExt on FirebaseFirestore {
  CollectionReference get userRef => collection(FirestoreContracts.userRef);
  CollectionReference get communityRef =>
      collection(FirestoreContracts.communityRef);
  CollectionReference get postRef => collection(FirestoreContracts.postRef);
  CollectionReference get commentRef =>
      collection(FirestoreContracts.commentRef);
}
