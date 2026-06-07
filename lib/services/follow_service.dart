import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final users = FirebaseFirestore.instance.collection("users");

  Future<void> follow(String myId, String targetId) async {
    await users.doc(myId).collection("following").doc(targetId).set({});

    await users.doc(targetId).collection("followers").doc(myId).set({});
  }

  Future<void> unfollow(String myId, String targetId) async {
    await users.doc(myId).collection("following").doc(targetId).delete();

    await users.doc(targetId).collection("followers").doc(myId).delete();
  }
}
