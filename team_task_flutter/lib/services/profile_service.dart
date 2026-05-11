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

    final memberSnapshot = await _firestore
        .collection('group_members')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    final groupIds = memberSnapshot.docs
        .map((doc) => (doc.data()['groupId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    int activeTasks = 0;
    int completedTasks = 0;

    for (int i = 0; i < groupIds.length; i += 10) {
      final chunk = groupIds.sublist(
        i,
        i + 10 > groupIds.length ? groupIds.length : i + 10,
      );

      final assignedTasks = await _firestore
          .collection('tasks')
          .where('groupId', whereIn: chunk)
          .where('assignedTo', isEqualTo: uid)
          .get();

      for (final doc in assignedTasks.docs) {
        final status = (doc.data()['status'] ?? '').toString().toLowerCase();
        if (status == 'done') {
          completedTasks++;
        } else {
          activeTasks++;
        }
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

    await user.updateDisplayName(trimmedName);

    final profileData = <String, dynamic>{
      'userId': user.uid,
      'name': trimmedName,
      'email': currentEmail,
      'avatar': avatar,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (trimmedEmail != currentEmail) {
      await user.verifyBeforeUpdateEmail(trimmedEmail);
      profileData['pendingEmail'] = trimmedEmail;
      profileData['emailChangeRequestedAt'] = FieldValue.serverTimestamp();
    } else {
      profileData['pendingEmail'] = FieldValue.delete();
      profileData['emailChangeRequestedAt'] = FieldValue.delete();
    }

    await _firestore.collection('users').doc(user.uid).set(
          profileData,
          SetOptions(merge: true),
        );
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

    try {
      await user.updatePassword(newPassword.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Phiên đăng nhập đã cũ. Vui lòng đăng xuất, đăng nhập lại rồi đổi mật khẩu.',
        );
      }
      throw Exception(e.message ?? 'Không đổi được mật khẩu');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}