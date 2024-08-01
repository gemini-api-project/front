import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:github_sign_in/github_sign_in.dart';

// Firebase Auth 인스턴스
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LangLink Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GitHub 로그인 버튼
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('Login with GitHub'),
              onPressed: () async {
                await _signInWithGitHub(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // GitHub 색상
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GitHub 로그인 메서드
  Future<void> _signInWithGitHub(BuildContext context) async {
    // GitHubSignIn 인스턴스 생성
    final GitHubSignIn gitHubSignIn = GitHubSignIn(
      clientId:
          '${dotenv.env['GITHUB_OAUTH_CLIENTID']}', // GitHub OAuth 클라이언트 ID
      clientSecret:
          '${dotenv.env['GITHUB_OAUTH_CLIENTSECRET']}', // GitHub OAuth 클라이언트 시크릿
      redirectUrl:
          '${dotenv.env['https://gemini-api-project-58d8c.firebaseapp.com/__/auth/handler']}', // 리다이렉트 URL
    );

    // 로그인 프로세스 시작
    final result = await gitHubSignIn.signIn(context);

    // 로그인 결과 처리
    switch (result.status) {
      case GitHubSignInResultStatus.ok:
        // GitHub 로그인 성공 시 Firebase 로그인
        final AuthCredential credential =
            GithubAuthProvider.credential(result.token!);
        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          final User? user = userCredential.user;

          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logged in as ${user.displayName}')),
            );
            // 로그인 후 메인 화면으로 이동
            Navigator.pushReplacementNamed(context, '/home');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firebase login failed: $e')),
          );
        }
        break;
      case GitHubSignInResultStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub login cancelled')),
        );
        break;
      case GitHubSignInResultStatus.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub login failed')),
        );
        break;
    }
  }
}
