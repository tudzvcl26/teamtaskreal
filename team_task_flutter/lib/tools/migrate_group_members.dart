import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('group_members').get();

  int migrated = 0;
  int skipped = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();

    final groupId = (data['groupId'] ?? '').toString();
    final userId = (data['userId'] ?? '').toString();

    if (groupId.isEmpty || userId.isEmpty) {
      print('Bỏ qua doc thiếu dữ liệu: ${doc.id}');
      skipped++;
      continue;
    }

    final newId = '${groupId}_$userId';
    final newRef = firestore.collection('group_members').doc(newId);

    if (doc.id == newId) {
      print('Đã đúng id rồi: $newId');
      skipped++;
      continue;
    }

    final newDoc = await newRef.get();

    if (!newDoc.exists) {
      await newRef.set({
        ...data,
        'id': newId,
      });
    }

    await doc.reference.delete();

    print('Đã migrate: ${doc.id} -> $newId');
    migrated++;
  }

  print('Xong. migrated=$migrated, skipped=$skipped');
}