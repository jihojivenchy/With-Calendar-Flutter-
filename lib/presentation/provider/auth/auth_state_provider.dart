import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth 상태를 감지하는 StreamProvider (전역 프로바이더)
/// 로그인/로그아웃 시 자동으로 상태가 변경됨
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 현재 로그인 여부를 반환하는 Provider
/// authStateProvider를 기반으로 boolean 값 제공
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});


// AuthStateProvider
//     ↓ 의존
// TabScreen