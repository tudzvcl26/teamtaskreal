import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileData {
  final String userId;
  final String name;
  final String email;
  final String avatar;
  final int activeTasks;
  final int completedTasks;

  ProfileData({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatar,
    required this.activeTasks,
    required this.completedTasks,
  });
}

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<ProfileData> getProfileData() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final uid = user.uid;

    String name = user.displayName ?? 'User';
    String email = user.email ?? '';
    String avatar = '';

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();

    if (userData != null) {
      name = userData['name'] ?? name;
      email = userData['email'] ?? email;
      avatar = userData['avatar'] ?? '';
    }

    final assignedTasks = await _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: uid)
        .get();

    int activeTasks = 0;
    int completedTasks = 0;

    for (final doc in assignedTasks.docs) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      if (status == 'done') {
        completedTasks++;
      } else {
        activeTasks++;
      }
    }

    return ProfileData(
      userId: uid,
      name: name,
      email: email,
      avatar: avatar,
      activeTasks: activeTasks,
      completedTasks: completedTasks,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String avatar,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedName.isEmpty) {
      throw Exception('Tên không được để trống');
    }

    if (trimmedEmail.isEmpty) {
      throw Exception('Email không được để trống');
    }

    final currentEmail = (user.email ?? '').trim().toLowerCase();

    if (trimmedEmail != currentEmail) {
      await user.verifyBeforeUpdateEmail(trimmedEmail);
    }

    await user.updateDisplayName(trimmedName);

    await _firestore.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'name': trimmedName,
      'email': trimmedEmail,
      'avatar': avatar,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    if (newPassword.trim().length < 6) {
      throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
    }

    await user.updatePassword(newPassword.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}