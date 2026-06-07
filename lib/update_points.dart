import 'package:cloud_firestore/cloud_firestore.dart';

class XPService {
  final users = FirebaseFirestore.instance.collection("users");

  Future<void> addPostXP(String userId) async {
    await users.doc(userId).update({"points": FieldValue.increment(10)});
  }

  Future<void> addLikeXP(String userId) async {
    await users.doc(userId).update({"points": FieldValue.increment(2)});
  }

  Future<void> addCommentXP(String userId) async {
    await users.doc(userId).update({"points": FieldValue.increment(3)});
  }
}
