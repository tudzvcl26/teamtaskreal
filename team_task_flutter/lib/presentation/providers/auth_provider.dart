import 'package:riverpod/riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider để theo dõi auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider để lấy current user UID
final currentUserIdProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? '';
});

// Provider để lấy current user email
final currentUserEmailProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.email ?? '';
});

// Provider để lấy current user info
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

// State Notifier cho login/signup
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseAuth.instance.signOut();
      return null;
    });
  }
}

// Provider cho auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});
