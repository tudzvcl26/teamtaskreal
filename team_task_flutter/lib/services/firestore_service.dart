import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  CollectionReference<Map<String, dynamic>> usersRef() {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> groupsRef() {
    return _firestore.collection('groups');
  }

  CollectionReference<Map<String, dynamic>> groupMembersRef() {
    return _firestore.collection('group_members');
  }

  CollectionReference<Map<String, dynamic>> tasksRef() {
    return _firestore.collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> commentsRef() {
    return _firestore.collection('comments');
  }

  CollectionReference<Map<String, dynamic>> notificationsRef() {
    return _firestore.collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> attachmentsRef() {
    return _firestore.collection('attachments');
  }

  CollectionReference<Map<String, dynamic>> activityLogsRef() {
    return _firestore.collection('activity_logs');
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).get();
  }

  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? builder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (builder != null) {
      query = builder(query);
    }

    return query.snapshots();
  }
}